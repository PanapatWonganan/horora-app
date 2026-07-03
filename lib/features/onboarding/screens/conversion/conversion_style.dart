import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Design tokens for the high-conversion onboarding flow.
///
/// Re-skinned onto the app's "Sacred Astrology" system ([AppColors]): a deep
/// temple indigo/plum radial canvas, a candle-gold CTA ramp, and warm ivory
/// cards. Member NAMES are kept stable so call sites in `conversion_widgets`
/// / `conversion_onboarding_screen` don't churn — every value below is a thin
/// alias of an [AppColors] token, no independent hexes.
class CvColors {
  CvColors._();

  // Indigo / plum canvas (radial, top-down) — Sacred backdrop ramp.
  static const Color bgTop = AppColors.softPlum;
  static const Color bgMid = AppColors.nightPlum;
  static const Color bgBottom = AppColors.templeIndigo;
  static const Color bgFooter = AppColors.templeIndigo; // CTA scrim base

  // Candle-gold CTA ramp
  static const Color goldLight = AppColors.candleGold;
  static const Color goldMid = AppColors.mutedGold;
  static const Color goldDeep = AppColors.deepGoldBrown;
  static const Color goldInk = AppColors.ink; // text on gold

  // Gold accents
  static const Color gold = AppColors.mutedGold;
  static const Color goldSoft = AppColors.candleGold;

  // Ivory cards
  static const Color ivory = AppColors.ivorySilk;
  static const Color ivoryInk = AppColors.ink;
  static const Color ivoryInkSoft = AppColors.softInk;
  static const Color ivoryDivider = AppColors.warmCardBorder;

  // Text on indigo
  static const Color cream = AppColors.onBackdrop;
  static const Color creamStatus = AppColors.onBackdrop;

  // Sage (verified checks)
  static const Color sage = AppColors.bodhiGreen;

  // Caption / label slate
  static const Color noteInk = AppColors.softPlum;

  static Color creamA(double a) => cream.withValues(alpha: a);
  static Color goldA(double a) => gold.withValues(alpha: a);
  static Color whiteA(double a) => Colors.white.withValues(alpha: a);
}

/// Typography roles, aligned with the app's Sacred UI kit: Kanit (display +
/// body — Thai/English), Fraunces (eyebrow/overline), matching
/// `SacredText.kanit` / `SacredOverline` in `sacred_ui.dart`.
class CvType {
  CvType._();

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = CvColors.cream,
    double height = 1.3,
  }) =>
      GoogleFonts.kanit(
          fontSize: size, fontWeight: weight, color: color, height: height);

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = CvColors.cream,
    double height = 1.55,
  }) =>
      GoogleFonts.kanit(
          fontSize: size, fontWeight: weight, color: color, height: height);

  static TextStyle eyebrow({Color color = CvColors.gold, double size = 12}) =>
      GoogleFonts.fraunces(
        fontSize: size < 12 ? 12 : size,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 3,
      );
}

/// Radial indigo background matching the design's phone-frame gradient.
class CvBackground extends StatelessWidget {
  final Widget child;
  const CvBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1),
          radius: 1.2,
          colors: [CvColors.bgTop, CvColors.bgMid, CvColors.bgBottom],
          stops: [0.0, 0.52, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// The gilded primary CTA used at the bottom of every screen.
class CvGoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const CvGoldButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [CvColors.goldLight, CvColors.goldMid, CvColors.goldDeep],
                stops: [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: CvColors.goldMid.withValues(alpha: 0.32),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: CvType.body(16,
                  weight: FontWeight.w700, color: CvColors.goldInk),
            ),
          ),
        ),
      ),
    );
  }
}

/// Plain text link (secondary actions like "ไว้ทีหลัง", "ข้ามไปก่อน").
class CvTextLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  const CvTextLink(
      {super.key, required this.label, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? CvColors.creamA(0.65),
        padding: const EdgeInsets.symmetric(vertical: 13),
        minimumSize: const Size(double.infinity, 0),
      ),
      child: Text(label,
          style: CvType.body(14,
              weight: FontWeight.w500, color: color ?? CvColors.creamA(0.65))),
    );
  }
}

/// Segmented step progress bar (gold = done/current, faint = upcoming).
class CvProgressBar extends StatelessWidget {
  final int current; // 1-based
  final int total;
  const CvProgressBar({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final filled = i < current;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 5),
            decoration: BoxDecoration(
              color: filled ? CvColors.goldMid : CvColors.whiteA(0.13),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
