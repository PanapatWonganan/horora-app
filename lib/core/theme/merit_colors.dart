import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Merit feature palette — "Sacred Astrology" silk + candlelight.
///
/// Constant NAMES are kept stable so the merit screens keep compiling; only the
/// VALUES are tuned to the temple palette: muted candle gold accents on warm
/// ivory / rice-paper cards, framed by a warm gold hairline. Merit-making
/// (ฝากทำบุญ) reads as quiet, premium and trustworthy — never bright/gambling
/// gold, never hard-sell.
class MeritColors {
  // Primary accent — candle gold → muted gold (calm, gilt, not neon).
  static const Color accent = AppColors.candleGold; // candle gold
  static const Color accentDark = AppColors.deepGoldBrown; // deep gold-brown

  static const List<Color> accentGradient = [
    AppColors.candleGold, // candle gold
    AppColors.mutedGold, // muted gold
  ];

  // Surfaces — warm ivory / rice-paper cards on the indigo canvas.
  static const Color cardBackground = AppColors.ivorySilk; // ivory card
  static const Color inputBackground = AppColors.ricePaper; // rice-paper wash
  static const Color inputBorder = AppColors.warmCardBorder; // warm gold hairline

  // Text — dark ink on warm ivory surfaces.
  static const Color textPrimary = AppColors.ink;
  static Color textSecondary = AppColors.ink.withValues(alpha: 0.75);
  static Color textHint = AppColors.softInk;

  // Price — deep gold-brown for emphasis (legible, gilt, not flashy).
  static const Color price = AppColors.deepGoldBrown;

  // Divider — warm gold hairline.
  static Color divider = AppColors.warmCardBorder;
}
