import 'package:flutter/material.dart';

/// Soft Celestial palette — a calm, pastel Thai-astrology aesthetic.
///
/// Variable names are kept stable (primary, darkBackground, lightText, …) so the
/// whole app re-themes by value change alone. For this LIGHT theme the historically
/// "dark*" surfaces are remapped to soft cream/white and "lightText" becomes the
/// deep ink used on pastel backgrounds.
class AppColors {
  // Brand — lavender lead with peach/mint companions (no flat purple gradients).
  static const Color primary = Color(0xFF8B6FE0); // soft lavender-violet
  static const Color secondary = Color(0xFFFFB0A0); // warm peach
  static const Color tertiary = Color(0xFF7FD6C2); // mint

  // Accent used for highlights / celestial sparkle.
  static const Color accent = Color(0xFFF2C879); // soft gold star

  // Background Colors — bg = celestial cream, "dark*" remapped to light surfaces.
  static const Color lightBackground = Color(0xFFFBF7FF); // pastel sky
  static const Color darkBackground = Color(0xFFFBF7FF); // (remapped) same cream
  static const Color cream = Color(0xFFFFF7EC);

  // Surface Colors — clean white cards on the pastel canvas.
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFFFFFFFF); // (remapped) white cards
  static const Color surfaceMuted = Color(0xFFF3ECFB); // very soft lavender wash

  // Text Colors — deep plum-ink reads softly on pastel, not harsh black.
  static const Color deepText = Color(0xFF2F2A40);
  static const Color lightText = Color(0xFF2F2A40); // (remapped) deep ink for light UI
  static const Color darkText = Color(0xFF2F2A40);
  static const Color mutedText = Color(0xFF8A82A0);

  // Status Colors — kept pastel-friendly.
  static const Color success = Color(0xFF5FB88E);
  static const Color warning = Color(0xFFF2C879);
  static const Color error = Color(0xFFE57C7C);
  static const Color info = Color(0xFF7FB0E8);

  // Gradient Colors — gentle multi-pastel blends, never a flat purple ramp.
  static const List<Color> primaryGradient = [
    Color(0xFFCDB7FF), // lavender
    Color(0xFFFFD7C2), // peach
  ];

  static const List<Color> mysticalGradient = [
    Color(0xFFB8A6F0), // lavender
    Color(0xFFBEE8FF), // sky blue
  ];

  static const List<Color> cosmicGradient = [
    Color(0xFFBEE8FF), // sky
    Color(0xFFC8F2DC), // mint
  ];

  // Zodiac Element Colors — softened to pastel.
  static const Color fireElement = Color(0xFFFF9E80); // soft coral
  static const Color earthElement = Color(0xFFA8D58F); // sage
  static const Color airElement = Color(0xFF9CC9F0); // soft blue
  static const Color waterElement = Color(0xFF8FD9D0); // aqua mint

  // Tarot Card Colors — pastel jewel tones.
  static const Color majorArcana = Color(0xFFE79BB8); // rose
  static const Color suitWands = Color(0xFFF2B873); // amber
  static const Color suitCups = Color(0xFF9CC9F0); // blue
  static const Color suitSwords = Color(0xFFA7B2C7); // slate
  static const Color suitPentacles = Color(0xFFA8D58F); // green

  // Misc Colors
  static const Color divider = Color(0xFFEDE6F7);
  static const Color disabled = Color(0xFFC5BED4);
  static final Color overlay = const Color(0xFF2F2A40).withValues(alpha: 0.35);

  // Dashboard Feature Colors — pastel-coded per feature.
  static const Color zodiacFire = Color(0xFFFF9E80);
  static const Color tarotMajor = Color(0xFFE79BB8);
  static const Color chatBubble = Color(0xFF9CC9F0);
  static const Color focusMeditation = Color(0xFFA8D58F);

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
