import 'package:flutter/material.dart';

class MeritColors {
  // Primary accent
  static const Color accent = Color(0xFFFFD700);
  static const Color accentDark = Color(0xFFFF8C00);

  static const List<Color> accentGradient = [
    Color(0xFFFFD700),
    Color(0xFFFF8C00),
  ];

  // Surfaces
  static const Color cardBackground = Color(0xFF1A1A2E);
  static const Color inputBackground = Color(0xFF2D2D44);
  static const Color inputBorder = Color(0xFF555566);

  // Text
  static const Color textPrimary = Colors.white;
  static Color textSecondary = Colors.white.withValues(alpha: 0.85);
  static Color textHint = Colors.white.withValues(alpha: 0.65);

  // Price
  static const Color price = Color(0xFFFFD700);

  // Divider
  static Color divider = Colors.white.withValues(alpha: 0.3);
}
