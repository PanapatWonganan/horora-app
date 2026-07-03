import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
// `String.characters` (Unicode grapheme clusters) comes from package:characters,
// which ships as part of the Flutter SDK and is already re-exported by
// package:flutter/material.dart — no new pub dependency needed.

/// Optional handle for imperatively skipping a [TypewriterRichText] reveal
/// (e.g. from a parent's tap handler that doesn't want to wrap the whole
/// widget in its own `GestureDetector`).
class TypewriterController {
  VoidCallback? _skip;

  void _attach(VoidCallback skip) => _skip = skip;
  void _detach() => _skip = null;

  /// Completes the reveal instantly, if attached to a mounted widget.
  void skip() => _skip?.call();
}

/// Reveals a prebuilt [TextSpan] progressively, character-by-character
/// (Unicode grapheme cluster, not UTF-16 code unit), while preserving every
/// span's style so bold/heading segments never flicker plain before turning
/// bold.
///
/// The reveal runs once per widget lifetime (tied to this State's ticker):
/// rebuilding with the same [span] does NOT restart the animation. To show a
/// different message, give this widget a new `key` (e.g. keyed by message
/// id) so Flutter creates a fresh State.
class TypewriterRichText extends StatefulWidget {
  /// The fully-styled span tree to reveal (e.g. from `SimpleMarkdown.parse`).
  final TextSpan span;

  /// Reveal speed. Ignored when [animate] is false.
  final double charsPerSecond;

  /// When false, the full [span] renders instantly with no animation.
  final bool animate;

  /// Called on every revealed-character tick (e.g. to autoscroll).
  final VoidCallback? onTick;

  /// Called once when the reveal finishes (or immediately if not animating).
  final VoidCallback? onDone;

  /// Optional controller so a parent can call `.skip()` to complete the
  /// reveal instantly without wrapping this widget in its own tap handler.
  final TypewriterController? controller;

  /// Inherited by the rendered `Text.rich` (alignment, overflow, etc).
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TypewriterRichText({
    super.key,
    required this.span,
    this.charsPerSecond = 45,
    this.animate = true,
    this.onTick,
    this.onDone,
    this.controller,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// Walks [span]'s tree and returns a new [TextSpan] truncated to the first
  /// [visibleChars] Unicode grapheme clusters, preserving every span's style
  /// (and any recognizable/gesture data) exactly. Extra chars/spans beyond
  /// the visible count are dropped entirely rather than shown empty, so a
  /// bold span either shows in full or not at all — never a plain-styled
  /// partial fragment.
  ///
  /// Pure + stateless: safe to unit test directly.
  static TextSpan truncate(TextSpan span, int visibleChars) {
    var remaining = visibleChars;

    InlineSpan? walk(InlineSpan node) {
      if (remaining <= 0) return null;
      if (node is! TextSpan) {
        // Non-text inline spans (e.g. WidgetSpan) aren't part of this app's
        // markdown output; pass through untouched and don't count toward
        // the visible budget.
        return node;
      }

      String? text;
      final nodeText = node.text;
      if (nodeText != null && nodeText.isNotEmpty) {
        final chars = nodeText.characters;
        if (chars.length <= remaining) {
          text = nodeText;
          remaining -= chars.length;
        } else {
          text = chars.take(remaining).toString();
          remaining = 0;
        }
      }

      List<InlineSpan>? children;
      if (node.children != null) {
        final truncatedChildren = <InlineSpan>[];
        for (final child in node.children!) {
          if (remaining <= 0) break;
          final walked = walk(child);
          if (walked != null) truncatedChildren.add(walked);
        }
        if (truncatedChildren.isNotEmpty) children = truncatedChildren;
      }

      if ((text == null || text.isEmpty) &&
          (children == null || children.isEmpty)) {
        return null;
      }

      return TextSpan(
        text: text,
        style: node.style,
        children: children,
        recognizer: node.recognizer,
        semanticsLabel: node.semanticsLabel,
        locale: node.locale,
        spellOut: node.spellOut,
      );
    }

    final walked = walk(span);
    if (walked is TextSpan) return walked;
    // Nothing visible yet — keep the root style so line-height/font don't
    // jump once the first characters land.
    return TextSpan(style: span.style);
  }

  /// Total grapheme-cluster length of [span]'s text content (used to know
  /// when the reveal is complete).
  static int graphemeLength(TextSpan span) {
    var total = 0;
    void walk(InlineSpan node) {
      if (node is TextSpan) {
        if (node.text != null) total += node.text!.characters.length;
        node.children?.forEach(walk);
      }
    }

    walk(span);
    return total;
  }

  @override
  State<TypewriterRichText> createState() => _TypewriterRichTextState();
}

class _TypewriterRichTextState extends State<TypewriterRichText>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  Duration _elapsedAtLastTick = Duration.zero;
  int _visibleChars = 0;
  int _totalChars = 0;
  bool _done = false;
  // Guards against re-running the initState-equivalent setup below more than
  // once: didChangeDependencies fires again on every inherited-widget change
  // (e.g. MediaQuery updates on rotation), but the reveal must only ever be
  // decided/started a single time per State.
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _totalChars = TypewriterRichText.graphemeLength(widget.span);
    widget.controller?._attach(_skip);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ??
        WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
            .disableAnimations;

    if (!widget.animate || disableAnimations || _totalChars == 0) {
      _visibleChars = _totalChars;
      _done = true;
      // Defer onDone so it fires after the first frame/build, matching the
      // animated path's contract (callback happens outside initState/build).
      if (widget.onDone != null) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onDone?.call();
        });
      }
      return;
    }

    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_done || !mounted) return;
    final deltaSeconds = (elapsed - _elapsedAtLastTick).inMicroseconds /
        Duration.microsecondsPerSecond;
    _elapsedAtLastTick = elapsed;

    final charsToAdd = deltaSeconds * widget.charsPerSecond;
    final next = (_visibleChars + charsToAdd).clamp(0, _totalChars).floor();

    if (next != _visibleChars) {
      setState(() {
        _visibleChars = next;
      });
      widget.onTick?.call();
    }

    if (_visibleChars >= _totalChars) {
      _finish();
    }
  }

  void _skip() {
    if (_done || !mounted) return;
    _ticker?.stop();
    setState(() {
      _visibleChars = _totalChars;
    });
    _finish();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    _ticker?.stop();
    widget.onDone?.call();
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleSpan = _done
        ? widget.span
        : TypewriterRichText.truncate(widget.span, _visibleChars);

    final text = Text.rich(
      visibleSpan,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );

    if (widget.controller != null) {
      // Parent owns tap-to-skip via the controller; don't double-handle taps.
      return text;
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _skip,
      child: text,
    );
  }
}
