import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static Color primary = const Color(0xFF9C27B0); // Purple
  static Color secondary = const Color(0xFF673AB7); // Deep Purple
  static Color tertiary = const Color(0xFF3F51B5); // Indigo

  // Background Colors
  static Color lightBackground = const Color(0xFFF8F9FA);
  static Color darkBackground = const Color(0xFF121212);

  // Surface Colors
  static Color lightSurface = const Color(0xFFFFFFFF);
  static Color darkSurface = const Color(0xFF1E1E1E);

  // Text Colors
  static Color lightText = const Color(0xFFF5F5F5);
  static Color darkText = const Color(0xFF212121);

  // Status Colors
  static Color success = const Color(0xFF4CAF50);
  static Color warning = const Color(0xFFFFC107);
  static Color error = const Color(0xFFF44336);
  static Color info = const Color(0xFF2196F3);

  // Gradient Colors
  static List<Color> primaryGradient = [
    const Color(0xFF9C27B0),
    const Color(0xFF673AB7),
  ];

  static List<Color> mysticalGradient = [
    const Color(0xFF673AB7),
    const Color(0xFF3F51B5),
  ];

  static List<Color> cosmicGradient = [
    const Color(0xFF3F51B5),
    const Color(0xFF2196F3),
  ];

  // Zodiac Element Colors
  static Color fireElement =
      const Color(0xFFFF5722); // Fire (Aries, Leo, Sagittarius)
  static Color earthElement =
      const Color(0xFF8BC34A); // Earth (Taurus, Virgo, Capricorn)
  static Color airElement =
      const Color(0xFF03A9F4); // Air (Gemini, Libra, Aquarius)
  static Color waterElement =
      const Color(0xFF00BCD4); // Water (Cancer, Scorpio, Pisces)

  // Tarot Card Colors
  static Color majorArcana = const Color(0xFFE91E63); // Major Arcana
  static Color suitWands = const Color(0xFFFF9800); // Wands
  static Color suitCups = const Color(0xFF2196F3); // Cups
  static Color suitSwords = const Color(0xFF607D8B); // Swords
  static Color suitPentacles = const Color(0xFF4CAF50); // Pentacles

  // Misc Colors
  static Color divider = const Color(0xFFE0E0E0);
  static Color disabled = const Color(0xFF9E9E9E);
  static Color overlay = Colors.black.withValues(alpha: 0.5);

  // Dashboard Feature Colors
  static Color zodiacFire = const Color(0xFFFF5722); // Zodiac feature
  static Color tarotMajor = const Color(0xFFE91E63); // Tarot feature
  static Color chatBubble = const Color(0xFF2196F3); // Chat feature
  static Color focusMeditation =
      const Color(0xFF4CAF50); // Focus meditation feature

  // Get color for zodiac sign
  static Color getZodiacColor(String zodiacSign) {
    switch (zodiacSign.toLowerCase()) {
      case 'aries':
      case 'leo':
      case 'sagittarius':
        return fireElement;
      case 'taurus':
      case 'virgo':
      case 'capricorn':
        return earthElement;
      case 'gemini':
      case 'libra':
      case 'aquarius':
        return airElement;
      case 'cancer':
      case 'scorpio':
      case 'pisces':
        return waterElement;
      default:
        return primary;
    }
  }

  // Get color for tarot suit
  static Color getTarotSuitColor(String suit) {
    switch (suit.toLowerCase()) {
      case 'major arcana':
        return majorArcana;
      case 'wands':
        return suitWands;
      case 'cups':
        return suitCups;
      case 'swords':
        return suitSwords;
      case 'pentacles':
      case 'coins':
        return suitPentacles;
      default:
        return primary;
    }
  }
}
