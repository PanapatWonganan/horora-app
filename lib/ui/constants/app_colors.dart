import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryColor = Color(0xFF673AB7); // Deep Purple
  static const Color primaryLightColor = Color(0xFFD1C4E9);
  static const Color primaryDarkColor = Color(0xFF512DA8);

  // Secondary colors
  static const Color secondaryColor = Color(0xFFFF9800); // Orange
  static const Color secondaryLightColor = Color(0xFFFFE0B2);
  static const Color secondaryDarkColor = Color(0xFFF57C00);

  // Accent colors
  static const Color accentColor = Color(0xFF00BCD4); // Cyan

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);

  // Text colors
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textLightColor = Colors.white;
  static const Color textDarkColor = Colors.black;

  // Star sign element colors
  static const Color fireColor =
      Color(0xFFFF5722); // Fire (Aries, Leo, Sagittarius)
  static const Color earthColor =
      Color(0xFF8BC34A); // Earth (Taurus, Virgo, Capricorn)
  static const Color airColor =
      Color(0xFF03A9F4); // Air (Gemini, Libra, Aquarius)
  static const Color waterColor =
      Color(0xFF3F51B5); // Water (Cancer, Scorpio, Pisces)

  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF2196F3);

  // Gradient colors
  static const List<Color> primaryGradient = [
    primaryColor,
    primaryDarkColor,
  ];

  static const List<Color> secondaryGradient = [
    secondaryColor,
    secondaryDarkColor,
  ];

  static const List<Color> cosmicGradient = [
    Color(0xFF2E0854),
    Color(0xFF8A2BE2),
    Color(0xFF5E35B1),
  ];

  // Get color for zodiac sign element
  static Color getElementColor(String element) {
    switch (element.toLowerCase()) {
      case 'fire':
        return fireColor;
      case 'earth':
        return earthColor;
      case 'air':
        return airColor;
      case 'water':
        return waterColor;
      default:
        return primaryColor;
    }
  }

  // Get color for zodiac sign
  static Color getZodiacColor(String sign) {
    switch (sign.toLowerCase()) {
      case 'aries':
      case 'leo':
      case 'sagittarius':
        return fireColor;
      case 'taurus':
      case 'virgo':
      case 'capricorn':
        return earthColor;
      case 'gemini':
      case 'libra':
      case 'aquarius':
        return airColor;
      case 'cancer':
      case 'scorpio':
      case 'pisces':
        return waterColor;
      default:
        return primaryColor;
    }
  }
}
