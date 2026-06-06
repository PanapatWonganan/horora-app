import 'package:flutter/material.dart';

/// Merit feature palette — "Soft Celestial" light theme.
///
/// Constant NAMES are kept stable so the merit screens keep compiling; only the
/// VALUES are flipped from the old dark scheme to a warm gold + peach accent on
/// a soft pastel base. Merit-making (donation) reads as gentle warmth here.
class MeritColors {
  // Primary accent — warm celestial gold + peach.
  static const Color accent = Color(0xFFF2C879); // soft gold star
  static const Color accentDark = Color(0xFFE6A15C); // deeper amber/peach

  static const List<Color> accentGradient = [
    Color(0xFFF2C879), // gold
    Color(0xFFFFB0A0), // peach
  ];

  // Surfaces — clean white/cream cards on the pastel canvas.
  static const Color cardBackground = Color(0xFFFFFFFF); // white card
  static const Color inputBackground = Color(0xFFF3ECFB); // soft lavender wash
  static const Color inputBorder = Color(0xFFEDE6F7); // gentle divider tone

  // Text — deep plum-ink on light surfaces.
  static const Color textPrimary = Color(0xFF2F2A40);
  static Color textSecondary = const Color(0xFF2F2A40).withValues(alpha: 0.75);
  static Color textHint = const Color(0xFF8A82A0);

  // Price — warm amber for emphasis.
  static const Color price = Color(0xFFE6A15C);

  // Divider
  static Color divider = const Color(0xFFEDE6F7);
}
