import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ── Sacred typography bridge ─────────────────────────────────────────────
///
/// Screens historically reached straight for `GoogleFonts.kanit(fontSize: ...)`
/// instead of `Theme.of(context).textTheme`, which is why sizes/weights drift
/// between screens over time (each call site re-invents the same handful of
/// roles). `_getTextTheme` in `app_theme.dart` now maps its named slots onto
/// the real Sacred roles the app renders — this file is the ergonomic surface
/// screens should reach for going forward: `context.sacredText.pageTitle`
/// etc., instead of repeating `Theme.of(context).textTheme.headlineSmall`.
///
/// Every getter here just reads the underlying [TextTheme] slot (see the slot
/// → role mapping documented on `AppTheme._getTextTheme`) and, where the role
/// is normally drawn on the indigo backdrop, swaps in the on-backdrop color
/// instead of the on-card ink the theme defaults to. Use the `OnBackdrop`
/// suffix getters (or pass `onBackdrop: true`) when the text sits directly on
/// [AppColors.lightBackground] / the celestial backdrop rather than on a
/// [SacredCard].
///
/// This is a pure presentation helper — no business logic, no state.
extension SacredTypographyX on BuildContext {
  SacredTypo get sacredText => SacredTypo(Theme.of(this).textTheme);
}

/// Semantic typography getters bridging [TextTheme] slots to Sacred roles.
/// See the slot → role mapping doc comment on `AppTheme._getTextTheme` for
/// exactly which Material slot backs each getter.
@immutable
class SacredTypo {
  final TextTheme _theme;

  const SacredTypo(this._theme);

  /// Home header greeting — 30 / w700 / h1.05 / ls -0.6. Drawn on the indigo
  /// backdrop, so this already resolves to [AppColors.onBackdrop].
  TextStyle get pageTitle =>
      (_theme.headlineMedium ?? const TextStyle()).copyWith(
        color: AppColors.onBackdrop,
      );

  /// Merit-hero large heading ("แนวทางวันนี้") — 24 / w700 / h1.15 / ls -0.3.
  /// Drawn on an ivory card, so this keeps the theme's on-card ink color.
  TextStyle get heroTitle => _theme.headlineSmall ?? const TextStyle();

  /// Section title text next to the sparkle glyph (mirrors
  /// `SacredSectionTitle` / Home's `_sectionTitle`) — 21 / w700 / ls -0.2.
  /// Defaults to on-backdrop color; pass [onCard] for the ivory-card variant.
  TextStyle sectionTitle({bool onCard = false}) =>
      (_theme.titleLarge ?? const TextStyle()).copyWith(
        color: onCard ? AppColors.deepText : AppColors.onBackdrop,
      );

  /// Card mini-heading (e.g. "ข้อมูลเพิ่มเติม", "คำแนะนำ") — 16 / w600.
  TextStyle get cardHeading => _theme.titleMedium ?? const TextStyle();

  /// Small emphasized label / list-row title — 14 / w600.
  TextStyle get emphasisLabel => _theme.titleSmall ?? const TextStyle();

  /// Primary card body copy — 16 / w400.
  TextStyle get body => _theme.bodyLarge ?? const TextStyle();

  /// Secondary card body copy / default label text — 14 / w400.
  TextStyle get bodyMedium => _theme.bodyMedium ?? const TextStyle();

  /// Body copy drawn directly on the indigo backdrop rather than a card.
  TextStyle get bodyOnBackdrop => bodyMedium.copyWith(
        color: AppColors.onBackdropMuted,
      );

  /// Fine print — 12 / w400.
  TextStyle get caption => _theme.bodySmall ?? const TextStyle();

  /// Small bold label (e.g. tab bar selected label) — 14 / w500.
  TextStyle get labelLarge => _theme.labelLarge ?? const TextStyle();

  /// Overline-adjacent chip / trust-strip label — 12 / w500. Defaults to the
  /// muted on-backdrop tone used by the trust strip; pass [onCard] for ink.
  TextStyle chipLabel({bool onCard = false}) =>
      (_theme.labelMedium ?? const TextStyle()).copyWith(
        color: onCard ? AppColors.deepText : AppColors.onBackdropMuted,
      );

  /// Editorial uppercase overline — 11.5 / w600 / ls 2.6. Note the app's
  /// English overlines normally render in the Fraunces display family via
  /// `SacredOverline`/`SacredText.display`; this Kanit-based fallback exists
  /// for any overline usage that intentionally stays in the Kanit family.
  /// Defaults to the muted on-backdrop tone; pass [onCard] for the ivory-card
  /// gold-brown tone.
  TextStyle overline({bool onCard = false}) =>
      (_theme.labelSmall ?? const TextStyle()).copyWith(
        color: onCard
            ? AppColors.deepGoldBrown.withValues(alpha: 0.85)
            : AppColors.onBackdropMuted,
      );
}
