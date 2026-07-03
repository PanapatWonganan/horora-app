import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:astrology_app/core/widgets/typewriter_rich_text.dart';
import 'package:astrology_app/core/utils/simple_markdown.dart';

/// Flattens a TextSpan tree into a list of (text, style) leaves, in order,
/// so tests can assert both the visible text AND which style each character
/// range carries without depending on TextSpan's own equality.
List<MapEntry<String, TextStyle?>> _leaves(InlineSpan span) {
  final out = <MapEntry<String, TextStyle?>>[];
  void walk(InlineSpan node) {
    if (node is TextSpan) {
      if (node.text != null && node.text!.isNotEmpty) {
        out.add(MapEntry(node.text!, node.style));
      }
      node.children?.forEach(walk);
    }
  }

  walk(span);
  return out;
}

String _visibleText(InlineSpan span) => _leaves(span).map((e) => e.key).join();

void main() {
  group('TypewriterRichText.truncate', () {
    test('truncating to 0 chars yields no visible text', () {
      const span = TextSpan(text: 'hello world');
      final result = TypewriterRichText.truncate(span, 0);
      expect(_visibleText(result), '');
    });

    test('truncating beyond total length returns full text unchanged', () {
      const span = TextSpan(text: 'hello');
      final result = TypewriterRichText.truncate(span, 999);
      expect(_visibleText(result), 'hello');
    });

    test('truncates plain text mid-string at the exact char count', () {
      const span = TextSpan(text: 'hello world');
      final result = TypewriterRichText.truncate(span, 5);
      expect(_visibleText(result), 'hello');
    });

    test(
        'bold span style is preserved when reveal lands fully inside it '
        '(no plain-then-bold flicker)', () {
      const boldStyle = TextStyle(fontWeight: FontWeight.w700);
      const span = TextSpan(
        style: TextStyle(fontSize: 14),
        children: [
          TextSpan(text: 'plain '),
          TextSpan(text: 'BOLD', style: boldStyle),
          TextSpan(text: ' tail'),
        ],
      );

      // Reveal stops 2 chars into the bold word ("plain BO").
      final result = TypewriterRichText.truncate(span, 8);
      final leaves = _leaves(result);

      expect(_visibleText(result), 'plain BO');
      // The visible fragment of the bold word must still carry boldStyle —
      // never fall back to the plain/base style.
      final boldLeaf = leaves.firstWhere((e) => e.key == 'BO');
      expect(boldLeaf.value, boldStyle);
    });

    test('bold span is entirely preserved once reveal passes it', () {
      const boldStyle = TextStyle(fontWeight: FontWeight.w700);
      const span = TextSpan(
        children: [
          TextSpan(text: 'plain '),
          TextSpan(text: 'BOLD', style: boldStyle),
          TextSpan(text: ' tail'),
        ],
      );

      // "plain BOLD ta" — bold word fully visible, tail partially visible.
      final result = TypewriterRichText.truncate(span, 13);
      final leaves = _leaves(result);

      expect(_visibleText(result), 'plain BOLD ta');
      final boldLeaf = leaves.firstWhere((e) => e.key == 'BOLD');
      expect(boldLeaf.value, boldStyle);
      final tailLeaf = leaves.firstWhere((e) => e.key == ' ta');
      expect(tailLeaf.value, isNull); // tail span carries no explicit style.
    });

    test(
        'spans entirely beyond the visible budget are dropped, not shown '
        'as empty-but-styled spans', () {
      const boldStyle = TextStyle(fontWeight: FontWeight.w700);
      const span = TextSpan(
        children: [
          TextSpan(text: 'AB'),
          TextSpan(text: 'CD', style: boldStyle),
        ],
      );

      final result = TypewriterRichText.truncate(span, 2);
      final leaves = _leaves(result);

      expect(_visibleText(result), 'AB');
      expect(leaves.any((e) => e.key.contains('C')), isFalse);
    });

    test(
        'root style is preserved even when zero characters are visible '
        '(prevents a line-height/font jump on the first tick)', () {
      const rootStyle = TextStyle(fontSize: 20);
      const span = TextSpan(
        style: rootStyle,
        children: [TextSpan(text: 'hello')],
      );

      final result = TypewriterRichText.truncate(span, 0);
      expect(result.style, rootStyle);
      expect(_visibleText(result), '');
    });

    test('SimpleMarkdown bold markers survive truncation with correct style',
        () {
      const base = TextStyle(fontSize: 14);
      final parsed = SimpleMarkdown.parse('ปกติ **ตัวหนา** ท้าย', base: base);

      // Reveal stops in the middle of the bold Thai word.
      final total = TypewriterRichText.graphemeLength(parsed);
      final result = TypewriterRichText.truncate(parsed, total - 4);
      final leaves = _leaves(result);

      // Every leaf whose text is a substring of the original bold word must
      // carry the bold weight, not the base weight.
      for (final leaf in leaves) {
        if ('ตัวหนา'.contains(leaf.key) && leaf.key.isNotEmpty) {
          expect(leaf.value?.fontWeight, FontWeight.w700,
              reason: 'partial bold fragment "${leaf.key}" lost bold style');
        }
      }
    });

    group('Thai grapheme safety', () {
      test('graphemeLength counts combining marks as part of one cluster', () {
        // "กิ่ง" — sara i (ิ) + mai ek (่) combine onto ก and ง stands alone.
        const thai = 'กิ่ง';
        const span = TextSpan(text: thai);
        // Visual/grapheme count should be 2 (ก+ิ+่ as one cluster, ง as
        // another) — NOT 4 UTF-16 code units.
        expect(TypewriterRichText.graphemeLength(span), 2);
      });

      test(
          'truncation never splits a base character from its combining '
          'marks (สระ/วรรณยุกต์ never appear detached)', () {
        // 'กิ่ง' 'มี' 'น้ำ' — includes sara/tone marks stacked on consonants.
        const thai = 'กิ่งมีน้ำ';
        const span = TextSpan(text: thai);
        final totalGraphemes = TypewriterRichText.graphemeLength(span);

        for (var n = 0; n <= totalGraphemes; n++) {
          final result = TypewriterRichText.truncate(span, n);
          final visible = _visibleText(result);
          // Re-deriving grapheme count of the visible text must equal n —
          // if a combining mark had been split off alone, the round trip
          // wouldn't match cleanly (an orphaned mark still composes with
          // nothing before it, changing the cluster count).
          expect(TypewriterRichText.graphemeLength(TextSpan(text: visible)), n,
              reason: 'truncate($n) produced "$visible"');
          // Every char in the visible text must be a valid prefix (no
          // reordering / no combining mark appearing before its base char
          // was included).
          expect(thai.startsWith(visible), isTrue);
        }
      });

      test('a single grapheme step at a time reveals whole clusters only', () {
        const thai =
            'น้ำ'; // น + ้ (mai tho) + ำ (sara am) — visually ~2-3 clusters
        const span = TextSpan(text: thai);
        final total = TypewriterRichText.graphemeLength(span);

        String? previous = '';
        for (var n = 1; n <= total; n++) {
          final visible = _visibleText(TypewriterRichText.truncate(span, n));
          expect(visible.length >= (previous?.length ?? 0), isTrue);
          previous = visible;
        }
        // Final step reveals everything.
        expect(previous, thai);
      });
    });
  });

  group('TypewriterRichText widget', () {
    testWidgets('animate: false renders full text with no timer pending',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypewriterRichText(
              span: TextSpan(text: 'hello world'),
              animate: false,
            ),
          ),
        ),
      );
      await tester.pump();

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(_visibleText(textWidget.textSpan!), 'hello world');
    });

    testWidgets('calls onDone exactly once when animate is false',
        (tester) async {
      var doneCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypewriterRichText(
              span: const TextSpan(text: 'hi'),
              animate: false,
              onDone: () => doneCount++,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(doneCount, 1);
    });

    testWidgets('progressively reveals characters over time when animating',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypewriterRichText(
              span: TextSpan(text: 'hello world'),
              animate: true,
              charsPerSecond: 10, // 100ms/char, easy to reason about
            ),
          ),
        ),
      );

      await tester.pump(); // first frame: 0 chars
      var textWidget = tester.widget<Text>(find.byType(Text));
      expect(_visibleText(textWidget.textSpan!), '');

      await tester.pump(const Duration(milliseconds: 250));
      textWidget = tester.widget<Text>(find.byType(Text));
      final partial = _visibleText(textWidget.textSpan!);
      expect(partial.isNotEmpty, isTrue);
      expect(partial.length < 'hello world'.length, isTrue);

      // Let it fully finish and settle so the pending ticker doesn't leak
      // into the next test.
      await tester.pump(const Duration(seconds: 2));
      textWidget = tester.widget<Text>(find.byType(Text));
      expect(_visibleText(textWidget.textSpan!), 'hello world');
    });

    testWidgets('tapping completes the reveal instantly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypewriterRichText(
              span: TextSpan(text: 'hello world'),
              animate: true,
              charsPerSecond: 5, // slow enough to still be mid-reveal
            ),
          ),
        ),
      );

      // Let a few characters render first so the GestureDetector has a
      // non-zero hit-test area (matches a user tapping mid-reveal, not at
      // the very first frame when zero characters are visible), then tap
      // by key instead of relying on the default hit-test center (Text
      // widgets sit top-left of an unconstrained Scaffold body, so their
      // vertical center can land outside the rendered glyphs' box).
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byType(TypewriterRichText), warnIfMissed: false);
      await tester.pump();

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(_visibleText(textWidget.textSpan!), 'hello world');
    });

    testWidgets('controller.skip() completes the reveal instantly',
        (tester) async {
      final controller = TypewriterController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypewriterRichText(
              span: const TextSpan(text: 'hello world'),
              animate: true,
              charsPerSecond: 1,
              controller: controller,
            ),
          ),
        ),
      );

      await tester.pump();
      controller.skip();
      await tester.pump();

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(_visibleText(textWidget.textSpan!), 'hello world');
    });

    testWidgets('rebuilding with the same key does not restart the reveal',
        (tester) async {
      var tickCount = 0;
      Widget build() => MaterialApp(
            home: Scaffold(
              body: TypewriterRichText(
                key: const ValueKey('same'),
                span: const TextSpan(text: 'hello world'),
                animate: true,
                charsPerSecond: 10,
                onTick: () => tickCount++,
              ),
            ),
          );

      await tester.pumpWidget(build());
      await tester.pump(const Duration(milliseconds: 250));
      final textWidget1 = tester.widget<Text>(find.byType(Text));
      final visibleAfterFirstRun = _visibleText(textWidget1.textSpan!);
      expect(visibleAfterFirstRun.isNotEmpty, isTrue);

      // Rebuild the tree (same key => same State) — must NOT reset progress
      // back to 0 chars.
      await tester.pumpWidget(build());
      await tester.pump();
      final textWidget2 = tester.widget<Text>(find.byType(Text));
      final visibleAfterRebuild = _visibleText(textWidget2.textSpan!);
      expect(visibleAfterRebuild.length >= visibleAfterFirstRun.length, isTrue);

      // Let it finish to avoid a dangling ticker between tests.
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('disposing mid-animation does not throw', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypewriterRichText(
              span: TextSpan(text: 'hello world'),
              animate: true,
              charsPerSecond: 1,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Replace the whole tree so the widget (and its ticker) is disposed
      // while the animation is still in-flight.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.pump();
      // No exception => timers/tickers were disposed cleanly.
    });

    testWidgets('MediaQuery.disableAnimations renders full text immediately',
        (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: TypewriterRichText(
                span: TextSpan(text: 'hello world'),
                animate: true,
                charsPerSecond: 1,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(_visibleText(textWidget.textSpan!), 'hello world');
    });
  });
}
