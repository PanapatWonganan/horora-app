import 'package:flutter/material.dart';

/// Sacred Astrology palette — muted temple indigo/plum, rice-paper cream and
/// candle gold. The mood is a quiet temple at dusk: mystical and astrological,
/// yet premium, calm and trustworthy for the ฝากทำบุญ (online merit) flow.
///
/// No neon purple/pink, no gambling-bright gold. Deep indigo/plum carries the
/// full-screen backdrops; warm ivory/rice-paper carries the cards; muted candle
/// gold is the single accent that ties Home and Merit together.
///
/// Variable NAMES are kept stable (primary, darkBackground, lightText, deepText,
/// …) so the whole app re-themes by value change alone. Two readings to keep in
/// mind:
///   • Backdrops (Home, Merit) are now DEEP indigo/plum → text drawn directly on
///     them uses [onBackdrop] / [onBackdropMuted] (light).
///   • Cards/sheets stay warm IVORY/rice-paper → text on them uses [deepText] /
///     [mutedText] (dark ink). These remain dark on purpose.
class AppColors {
  // ── Sacred Astrology source palette ────────────────────────────────────────
  static const Color templeIndigo = Color(0xFF241C35); // deep temple indigo
  static const Color nightPlum = Color(0xFF332647); // warm night plum
  static const Color softPlum = Color(0xFF4A3558); // soft plum
  static const Color ivorySilk = Color(0xFFFBF4E8); // ivory silk
  static const Color ricePaper = Color(0xFFF6EAD8); // rice paper
  static const Color warmCardBorder = Color(0xFFE4CFA8); // warm card border
  static const Color mutedGold = Color(0xFFC9A24B); // muted gold
  static const Color candleGold = Color(0xFFE0B86A); // candle gold
  static const Color deepGoldBrown = Color(0xFF8A6428); // deep gold brown
  static const Color templeVermilion = Color(0xFF9E3B2E); // temple vermilion
  static const Color bodhiGreen = Color(0xFF5F7A61); // bodhi green
  static const Color ink = Color(0xFF2A2620); // ink (on ivory)
  static const Color softInk = Color(0xFF786B5B); // soft ink (on ivory)

  // Brand — muted plum lead, candle-gold + bodhi-green companions. Calm, not
  // neon. `primary` is the plum used for icon tints / accents on light cards.
  static const Color primary = softPlum; // muted temple plum
  static const Color secondary = candleGold; // candlelight warmth
  static const Color tertiary = bodhiGreen; // temple green

  // Accent used for highlights / celestial sparkle — candle gold.
  static const Color accent = candleGold;

  // Background Colors — full-screen backdrops are deep indigo; "light*" surfaces
  // remain warm ivory for cards/sheets. (darkBackground == backdrop base.)
  static const Color lightBackground = templeIndigo; // deep indigo canvas
  static const Color darkBackground = templeIndigo; // (remapped) same indigo
  static const Color cream = ivorySilk;

  // Surface Colors — warm ivory / rice-paper cards on the indigo canvas.
  static const Color lightSurface = ivorySilk;
  static const Color darkSurface = ivorySilk; // (remapped) ivory cards
  static const Color surfaceMuted = ricePaper; // soft rice-paper wash

  // Text Colors — dark INK reads on ivory cards (kept dark on purpose).
  static const Color deepText = ink;
  static const Color lightText = ink; // (remapped) ink for content on cards
  static const Color darkText = ink;
  static const Color mutedText = softInk;

  // On-backdrop text — light tones used ONLY for text/marks drawn directly on
  // the deep indigo/plum backdrop (greeting, section titles, overlines).
  static const Color onBackdrop = Color(0xFFF4ECDD); // warm ivory on indigo
  static const Color onBackdropMuted = Color(0xFFB8A9C4); // muted lilac-grey

  // Status Colors — temple-toned, calm.
  static const Color success = bodhiGreen;
  static const Color warning = candleGold;
  static const Color error = templeVermilion;
  static const Color info = Color(0xFF7C7A9E); // muted indigo-grey

  // Gradient Colors — deep indigo→plum ramps for backdrops/wheels, never a
  // saturated/neon purple ramp.
  static const List<Color> primaryGradient = [
    softPlum, // soft plum
    nightPlum, // night plum
  ];

  static const List<Color> mysticalGradient = [
    nightPlum, // night plum
    templeIndigo, // deep indigo
  ];

  static const List<Color> cosmicGradient = [
    softPlum, // soft plum
    templeIndigo, // deep indigo
  ];

  // Candle-gold accent ramp (CTAs, gilt edges) — candle → muted, not bright.
  static const List<Color> goldGradient = [
    candleGold,
    mutedGold,
  ];

  // Zodiac Element Colors — muted, temple-toned (no neon).
  static const Color fireElement = templeVermilion; // ember vermilion
  static const Color earthElement = deepGoldBrown; // gold-brown earth
  static const Color airElement = Color(0xFF8C86A8); // muted indigo air
  static const Color waterElement = Color(0xFF5C7480); // slate teal water

  // Tarot Card Colors — muted jewel/temple tones.
  static const Color majorArcana = mutedGold; // gilt
  static const Color suitWands = candleGold; // candle gold
  static const Color suitCups = Color(0xFF5C7480); // slate teal
  static const Color suitSwords = Color(0xFF8C86A8); // muted indigo
  static const Color suitPentacles = bodhiGreen; // temple green

  // Misc Colors
  static const Color divider = warmCardBorder; // warm hairline on cards
  static const Color disabled = Color(0xFFCBBFA8); // warm muted
  static final Color overlay = const Color(0xFF241C35).withValues(alpha: 0.45);

  // Dashboard Feature Colors — temple-coded per feature.
  static const Color zodiacFire = templeVermilion;
  static const Color tarotMajor = mutedGold;
  static const Color chatBubble = softPlum;
  static const Color focusMeditation = bodhiGreen;

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
