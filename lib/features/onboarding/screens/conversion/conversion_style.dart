import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the high-conversion onboarding flow.
///
/// These mirror the imported "Onboarding Flow" Claude Design exactly — a deep
/// indigo→plum radial canvas, a candle-gold CTA ramp, and warm ivory cards.
/// Kept local to the onboarding feature so the funnel can stay 1:1 with the
/// design without disturbing the rest of the app's [AppColors].
class CvColors {
  CvColors._();

  // Indigo / plum canvas (radial, top-down)
  static const Color bgTop = Color(0xFF3B2B51);
  static const Color bgMid = Color(0xFF281D3C);
  static const Color bgBottom = Color(0xFF1C1430);
  static const Color bgFooter = Color(0xFF1F1733); // CTA scrim base

  // Candle-gold CTA ramp
  static const Color goldLight = Color(0xFFF2D486);
  static const Color goldMid = Color(0xFFD2A043);
  static const Color goldDeep = Color(0xFFC2902F);
  static const Color goldInk = Color(0xFF5B4318); // text on gold

  // Gold accents
  static const Color gold = Color(0xFFCDA64E);
  static const Color goldSoft = Color(0xFFE0B85A);

  // Ivory cards
  static const Color ivory = Color(0xFFF4EAD7);
  static const Color ivoryInk = Color(0xFF3A2C1C);
  static const Color ivoryInkSoft = Color(0xFF6B552F);
  static const Color ivoryDivider = Color(0xFFE3D3B3);

  // Text on indigo
  static const Color cream = Color(0xFFF4EDDE);
  static const Color creamStatus = Color(0xFFEFE7D8);

  // Sage (verified checks)
  static const Color sage = Color(0xFFA3BD6B);

  // Caption / label slate
  static const Color noteInk = Color(0xFF352A4C);

  static Color creamA(double a) => cream.withValues(alpha: a);
  static Color goldA(double a) => gold.withValues(alpha: a);
  static Color whiteA(double a) => Colors.white.withValues(alpha: a);
}

/// Typography roles from the design: Trirong (display serif),
/// IBM Plex Sans Thai (body), Cormorant Garamond (eyebrows).
class CvType {
  CvType._();

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color color = CvColors.cream,
    double height = 1.3,
  }) =>
      GoogleFonts.trirong(
          fontSize: size, fontWeight: weight, color: color, height: height);

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = CvColors.cream,
    double height = 1.55,
  }) =>
      GoogleFonts.ibmPlexSansThai(
          fontSize: size, fontWeight: weight, color: color, height: height);

  static TextStyle eyebrow({Color color = CvColors.gold, double size = 11}) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
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
        foregroundColor: color ?? CvColors.creamA(0.55),
        padding: const EdgeInsets.symmetric(vertical: 13),
        minimumSize: const Size(double.infinity, 0),
      ),
      child: Text(label,
          style: CvType.body(14,
              weight: FontWeight.w500, color: color ?? CvColors.creamA(0.55))),
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

/// Faux iOS status bar to match the design's phone mockups.
class CvStatusBar extends StatelessWidget {
  final Widget? trailing;
  const CvStatusBar({super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('9:41',
              style: CvType.body(13,
                  weight: FontWeight.w600, color: CvColors.creamStatus)),
          trailing ??
              Text('●●●  ▮',
                  style: CvType.body(11, color: CvColors.creamA(0.85))
                      .copyWith(letterSpacing: 2)),
        ],
      ),
    );
  }
}
