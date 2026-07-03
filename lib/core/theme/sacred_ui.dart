import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'celestial_effects.dart';
import '../utils/app_icons.dart';

/// ── Sacred UI kit ───────────────────────────────────────────────────────────
///
/// The single source of truth for the app's "Sacred Astrology" visual language,
/// lifted out of the approved Home screen so every other screen can wear the
/// exact same structure, palette, spacing, typography and icon language:
///
///   • deep temple indigo/plum full-screen backdrop (celestialBackdrop) with a
///     couple of restrained plum/candle glows and a faint grain overlay,
///   • warm ivory / rice-paper cards with a warm gold hairline + soft plum lift,
///   • candle gold used sparingly (icon coins, hairline dividers, CTA edges),
///   • editorial English overline (Fraunces serif) → Thai heading (Kanit) →
///     calm muted body → quiet CTA,
///   • a gentle press-scale micro-interaction on tappable surfaces.
///
/// These are pure presentation helpers — no business logic, no navigation, no
/// state of the app passes through here. Screens keep their own logic and simply
/// render through these building blocks so the whole product reads as one calm,
/// trustworthy spiritual companion.

class SacredText {
  SacredText._();

  /// Editorial display style (characterful serif) for English accents/numerals —
  /// the counterpoint to the Thai Kanit headings. Mirrors Home's `_displayStyle`.
  static TextStyle display({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 0.2,
    double height = 1.0,
  }) {
    return GoogleFonts.fraunces(
      fontSize: fontSize,
      color: color ?? AppColors.deepText,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// Thai/body heading + label style (Kanit).
  static TextStyle kanit({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.kanit(
      fontSize: fontSize,
      color: color ?? AppColors.deepText,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}

/// Small uppercase letter-spaced English overline for an editorial feel above a
/// Thai title. On the indigo backdrop use the muted on-backdrop tone; on ivory
/// cards pass [color] = a deep-gold-brown.
class SacredOverline extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;

  const SacredOverline(this.text, {super.key, this.color, this.fontSize = 11.5});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: SacredText.display(
        fontSize: fontSize,
        color: color ?? AppColors.onBackdropMuted,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.6,
      ),
    );
  }
}

/// A section heading drawn on the indigo backdrop: an editorial overline + a
/// Thai title (Kanit) led by a small candle-gold sparkle. Mirrors Home's
/// `_sectionTitle`. Use [onCard] = true when the title sits on an ivory card so
/// the text switches to dark ink.
class SacredSectionTitle extends StatelessWidget {
  final String title;
  final String? overline;
  final bool onCard;

  const SacredSectionTitle(
    this.title, {
    super.key,
    this.overline,
    this.onCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = onCard ? AppColors.deepText : AppColors.onBackdrop;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null) ...[
          SacredOverline(
            overline!,
            color: onCard
                ? AppColors.deepGoldBrown.withValues(alpha: 0.85)
                : AppColors.onBackdropMuted,
          ),
          const SizedBox(height: 5),
        ],
        Row(
          children: [
            SvgPicture.asset(
              AppIcons.sparkleFilled,
              width: 18,
              height: 18,
              colorFilter:
                  const ColorFilter.mode(AppColors.accent, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: SacredText.kanit(
                  color: titleColor,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The full-screen "temple at dusk" backdrop: the celestial gradient + two
/// restrained plum glows + one faint candle-gold warmth + a low grain overlay.
/// Drop your page content on top via [child]. This is the same atmosphere Home
/// and the merit hero use, factored out so any screen can sit on it.
class SacredBackground extends StatelessWidget {
  final Widget child;

  /// When false, omit the decorative star specks (e.g. dense form screens).
  final bool showSpecks;

  const SacredBackground({super.key, required this.child, this.showSpecks = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: celestialBackdrop),
      child: Stack(
        children: [
          const Positioned(
            top: -130,
            left: -100,
            child: CelestialGlow(
              size: 300,
              color: AppColors.primary,
              intensity: 0.18,
            ),
          ),
          const Positioned(
            bottom: -120,
            right: -110,
            child: CelestialGlow(
              size: 300,
              color: AppColors.primary,
              intensity: 0.14,
            ),
          ),
          const Positioned(
            top: -70,
            right: -90,
            child: CelestialGlow(
              size: 220,
              color: AppColors.accent,
              intensity: 0.10,
            ),
          ),
          const Positioned.fill(child: GrainOverlay(opacity: 0.026)),
          if (showSpecks) ...[
            Positioned(
              top: 90,
              right: 44,
              child: _starSpeck(13, 0.28),
            ),
            Positioned(
              top: 240,
              left: 56,
              child: _starSpeck(9, 0.22),
            ),
          ],
          child,
        ],
      ),
    );
  }

  Widget _starSpeck(double size, double opacity) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: SvgPicture.asset(
          AppIcons.sparkle,
          width: size,
          height: size,
          colorFilter:
              const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
      ),
    );
  }
}

/// A Scaffold pre-dressed with the Sacred backdrop. Keeps the deep-indigo base
/// behind any system bars and lets bottom nav / app bars sit on the same
/// atmosphere. Behaviour-free wrapper — pass [bottomNavigationBar],
/// [appBar] etc. through as usual.
class SacredScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showSpecks;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  const SacredScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showSpecks = true,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: SacredBackground(showSpecks: showSpecks, child: body),
    );
  }
}

/// A calm in-page header bar drawn directly on the indigo backdrop: an optional
/// back chip, an editorial overline + Thai title, and an optional trailing
/// widget. Replaces the bright corporate AppBars across the app. Behaviour-free:
/// pass [onBack] (defaults to Navigator.maybePop) and [trailing].
class SacredHeader extends StatelessWidget {
  final String title;
  final String? overline;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SacredHeader({
    super.key,
    required this.title,
    this.overline,
    this.showBack = true,
    this.onBack,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBack) ...[
            _BackChip(onTap: onBack ?? () => Navigator.maybePop(context)),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (overline != null) ...[
                  SacredOverline(overline!),
                  const SizedBox(height: 3),
                ],
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SacredText.kanit(
                    color: AppColors.onBackdrop,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _BackChip extends StatelessWidget {
  final VoidCallback onTap;
  const _BackChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.onBackdrop.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: AppColors.onBackdrop.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 17,
          color: AppColors.onBackdrop,
        ),
      ),
    );
  }
}

/// A warm ivory / rice-paper card — the app's primary content surface. Matches
/// Home's hero card: ivory→rice-paper gradient, warm gold hairline, soft plum
/// lift. Wrap any block of content in this for the shared card rhythm.
class SacredCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final bool highlight;

  const SacredCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 22,
    this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ivorySilk, AppColors.ricePaper],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: highlight
              ? AppColors.candleGold.withValues(alpha: 0.8)
              : AppColors.warmCardBorder.withValues(alpha: 0.7),
          width: highlight ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.templeIndigo
                .withValues(alpha: highlight ? 0.22 : 0.16),
            blurRadius: 22,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return SacredPressable(
      onTap: onTap!,
      borderRadius: BorderRadius.circular(radius),
      child: card,
    );
  }
}

/// A small candle-gold icon coin — the sparing gold accent used beside titles
/// and list rows across the app (matches Home's merit-hero icon coin).
class SacredIconCoin extends StatelessWidget {
  final String svgAsset;
  final double size;
  final double padding;

  const SacredIconCoin(
    this.svgAsset, {
    super.key,
    this.size = 24,
    this.padding = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.candleGold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SvgIcon(
        svgAsset,
        size: size,
        color: AppColors.deepGoldBrown,
      ),
    );
  }
}

/// A gold hairline divider that fades out — one of the few gold notes on a card.
class SacredGoldDivider extends StatelessWidget {
  const SacredGoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.candleGold.withValues(alpha: 0.55),
            AppColors.candleGold.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

/// The primary action button: a quiet candle-gold outlined CTA (gold edge + a
/// faint gold wash + ink-gold label). Reserved for the key action on a card —
/// calm, premium, never a loud fill. Set [filled] = true for the single most
/// important action on a flow (solid candle-gold).
class SacredPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final String? trailingSvg;
  final String? leadingSvg;
  final bool filled;
  final bool enabled;

  /// When true, shows a small spinner in place of the label/icons and
  /// disables the tap — mirrors the loading state the old GradientButton /
  /// raw ElevatedButtons offered.
  final bool isLoading;

  const SacredPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.trailingSvg,
    this.leadingSvg,
    this.filled = false,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final on = enabled && onTap != null && !isLoading;
    final labelColor = filled ? Colors.white : AppColors.deepGoldBrown;

    final inner = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: filled
            ? const LinearGradient(
                colors: [AppColors.candleGold, AppColors.deepGoldBrown],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: filled ? null : AppColors.candleGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: filled
            ? null
            : Border.all(
                color: AppColors.candleGold.withValues(alpha: 0.7),
                width: 1.2,
              ),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: AppColors.deepGoldBrown.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: isLoading
          ? Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: labelColor,
                  strokeWidth: 2.2,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingSvg != null) ...[
                  SvgIcon(leadingSvg!, size: 18, color: labelColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: SacredText.kanit(
                    color: labelColor,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (trailingSvg != null) ...[
                  const SizedBox(width: 8),
                  SvgIcon(trailingSvg!, size: 18, color: labelColor),
                ],
              ],
            ),
    );

    return Opacity(
      opacity: on || isLoading ? 1 : 0.5,
      child: SacredPressable(
        onTap: on ? onTap! : () {},
        borderRadius: BorderRadius.circular(16),
        child: inner,
      ),
    );
  }
}

/// A quiet text/link action (ink-gold label + arrow) — the secondary CTA used
/// where a full button would be too loud.
class SacredTextAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? trailingSvg;
  final Color? color;

  const SacredTextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.trailingSvg,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.deepGoldBrown;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: SacredText.kanit(
              color: c,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailingSvg != null) ...[
            const SizedBox(width: 4),
            SvgIcon(trailingSvg!, size: 15, color: c),
          ],
        ],
      ),
    );
  }
}

/// A trust chip strip drawn on the backdrop — faint ivory-on-plum chips with a
/// small bodhi-green check. Reassurance, never a sales pitch. Mirrors Home's
/// `_buildTrustStrip`.
class SacredTrustStrip extends StatelessWidget {
  final List<(IconData, String)> items;
  const SacredTrustStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (icon, label) in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.onBackdrop.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: AppColors.onBackdrop.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: AppColors.bodhiGreen.withValues(alpha: 0.95),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: SacredText.kanit(
                    color: AppColors.onBackdropMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Shared input decoration for forms on ivory cards: rice-paper fill, warm gold
/// hairline that warms to candle gold on focus, ink labels. Keeps every form in
/// the app reading the same. Pass a [prefixIcon] widget if desired.
InputDecoration sacredInputDecoration({
  String? label,
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.ricePaper,
    labelStyle: SacredText.kanit(color: AppColors.softInk, fontSize: 14),
    hintStyle: SacredText.kanit(
      color: AppColors.softInk.withValues(alpha: 0.7),
      fontSize: 14,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.warmCardBorder, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: AppColors.warmCardBorder.withValues(alpha: 0.8),
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.candleGold, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 1.4),
    ),
    errorStyle: SacredText.kanit(color: AppColors.error, fontSize: 12),
  );
}

/// Gentle press-scale + soft splash wrapper. Scales the child down slightly
/// while tapped. Identical micro-interaction to Home's `_PressScale`.
class SacredPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const SacredPressable({
    super.key,
    required this.child,
    required this.onTap,
    BorderRadius? borderRadius,
  }) : borderRadius =
            borderRadius ?? const BorderRadius.all(Radius.circular(20));

  @override
  State<SacredPressable> createState() => _SacredPressableState();
}

class _SacredPressableState extends State<SacredPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (mounted && _pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
