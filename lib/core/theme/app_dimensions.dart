import 'package:flutter/material.dart';

/// ── Design tokens: radius ────────────────────────────────────────────────
///
/// Centralizes the border-radius scale so cards, buttons, inputs and dialogs
/// stop drifting between arbitrary literals. Values match what sacred_ui.dart
/// and app_theme.dart already use most often — this is a behavior-preserving
/// naming pass, not a redesign.
class AppRadius {
  AppRadius._();

  /// Small chips / icon coins / back-chip (matches existing ~12-13 literals).
  static const double sm = 12.0;

  /// Buttons, inputs, cards-in-theme, chips — the most common radius in the
  /// app (ElevatedButton, OutlinedButton, InputDecorationTheme, CardTheme...).
  static const double md = 16.0;

  /// SacredCard — the app's primary content surface.
  static const double card = 22.0;

  /// Dialogs / bottom sheets.
  static const double dialog = 24.0;

  /// Fully-rounded pill shapes (trust strip chips, etc).
  static const double pill = 40.0;
}

/// ── Design tokens: spacing ───────────────────────────────────────────────
///
/// Centralizes the spacing scale used for gaps and paddings across screens.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;

  /// The standard page gutter used by profile/settings/history screens.
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: xl);
}
