import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: AppColors.darkText,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.onBackdrop,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.kanit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onBackdrop,
        ),
      ),
      textTheme: _getTextTheme(isDark: false),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: GoogleFonts.kanit(
          fontSize: 16,
          color: AppColors.darkText.withValues(alpha: 0.5),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkText.withValues(alpha: 0.1),
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkText.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.kanit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.kanit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.dialog)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightSurface,
        contentTextStyle: GoogleFonts.kanit(
          fontSize: 14,
          color: AppColors.deepText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: AppColors.candleGold.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.onBackdrop,
        unselectedLabelColor: AppColors.onBackdropMuted,
        indicatorColor: AppColors.candleGold,
        labelStyle: GoogleFonts.kanit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.kanit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        side: BorderSide(color: AppColors.darkText.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.darkText.withValues(alpha: 0.5);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.darkText.withValues(alpha: 0.2);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.darkText.withValues(alpha: 0.2),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.darkText.withValues(alpha: 0.1),
        linearTrackColor: AppColors.darkText.withValues(alpha: 0.1),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        disabledColor: AppColors.darkText.withValues(alpha: 0.1),
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.kanit(
          fontSize: 14,
          color: AppColors.darkText,
        ),
        secondaryLabelStyle: GoogleFonts.kanit(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      // The bundled Kanit font files are 0-byte placeholders (see pubspec),
      // so a literal 'Kanit' family name would fall back to the system font
      // for any widget using a plain TextStyle. Resolve to GoogleFonts'
      // runtime-loaded Kanit family instead so the raw-family fallback works.
      fontFamily: GoogleFonts.kanit().fontFamily,
    );
  }

  // Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: AppColors.lightText,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.kanit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightText,
        ),
      ),
      textTheme: _getTextTheme(isDark: true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.kanit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: GoogleFonts.kanit(
          fontSize: 16,
          color: AppColors.lightText.withValues(alpha: 0.5),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.lightText.withValues(alpha: 0.1),
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightText.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.kanit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.kanit(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.dialog)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightSurface,
        contentTextStyle: GoogleFonts.kanit(
          fontSize: 14,
          color: AppColors.darkText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: AppColors.candleGold.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.lightText.withValues(alpha: 0.5),
        indicatorColor: AppColors.primary,
        labelStyle: GoogleFonts.kanit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.kanit(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        side: BorderSide(color: AppColors.lightText.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.lightText.withValues(alpha: 0.5);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.lightText.withValues(alpha: 0.2);
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.lightText.withValues(alpha: 0.2),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.lightText.withValues(alpha: 0.1),
        linearTrackColor: AppColors.lightText.withValues(alpha: 0.1),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        disabledColor: AppColors.lightText.withValues(alpha: 0.1),
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.secondary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.kanit(
          fontSize: 14,
          color: AppColors.lightText,
        ),
        secondaryLabelStyle: GoogleFonts.kanit(
          fontSize: 14,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      // See lightTheme() for why this resolves via GoogleFonts instead of
      // the literal (unavailable) 'Kanit' asset family.
      fontFamily: GoogleFonts.kanit().fontFamily,
    );
  }

  // Text Theme
  //
  // ── Slot → Sacred role mapping ─────────────────────────────────────────
  // The Sacred UI kit (see `sacred_ui.dart`) and the flagship screens (Home,
  // Horoscope) render text via ad-hoc `GoogleFonts.kanit(...)` calls rather
  // than through this TextTheme, which is why these slots historically drifted
  // from what actually ships. This realigns the named Material slots to the
  // real, observed Sacred roles so `context.sacredText` (see
  // `sacred_typography.dart`) can read them instead of hardcoding values a
  // second time. Slots not used by any Sacred role keep their Material
  // defaults (display*, headlineLarge) since nothing in the app renders them.
  //
  //   displayLarge/Medium/Small, headlineLarge — unused by Sacred screens;
  //     left at Material defaults for any incidental default-Text usage.
  //   headlineMedium  → 30 / w700 / h1.05 / ls -0.6
  //     Home header greeting ("สวัสดีค่ะ คุณ...") — the single biggest,
  //     boldest line on the backdrop.
  //   headlineSmall   → 24 / w700 / h1.15 / ls -0.3
  //     Merit-hero large heading ("แนวทางวันนี้") — big heading on an ivory
  //     card.
  //   titleLarge      → 21 / w700 / ls -0.2
  //     Section title text next to the sparkle glyph (SacredSectionTitle /
  //     Home's `_sectionTitle`) — the app's standard section heading.
  //   titleMedium     → 16 / w600
  //     Card mini-heading (e.g. "ข้อมูลเพิ่มเติม", "คำแนะนำ").
  //   titleSmall      → 14 / w600
  //     Small emphasized label / list-row title.
  //   bodyLarge       → 16 / w400
  //     Primary card body copy.
  //   bodyMedium      → 14 / w400
  //     Secondary card body copy / default label text.
  //   bodySmall       → 12 / w400
  //     Fine print.
  //   labelLarge      → 14 / w500
  //     Small bold label (e.g. tab bar selected label).
  //   labelMedium     → 12 / w500
  //     Overline-adjacent chip / trust-strip label text.
  //   labelSmall      → 11.5 / w600 / ls 2.6
  //     Editorial uppercase overline (SacredOverline) — note this one keeps
  //     its own Fraunces-family styling via `SacredOverline`/`SacredText`,
  //     this slot exists so `context.sacredText.overline` has a Kanit-based
  //     fallback for any non-editorial overline usage.
  //
  // NOTE: color here stays keyed to `textColor` (the on-card ink) — screens
  // drawing directly on the indigo backdrop must still swap in
  // `AppColors.onBackdrop` / `onBackdropMuted` explicitly (see
  // `sacred_typography.dart`, which does this for you).
  static TextTheme _getTextTheme({required bool isDark}) {
    final textColor = isDark ? AppColors.lightText : AppColors.darkText;

    return TextTheme(
      displayLarge: GoogleFonts.kanit(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displayMedium: GoogleFonts.kanit(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displaySmall: GoogleFonts.kanit(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineLarge: GoogleFonts.kanit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      // Home header greeting.
      headlineMedium: GoogleFonts.kanit(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.05,
        letterSpacing: -0.6,
      ),
      // Merit-hero large heading.
      headlineSmall: GoogleFonts.kanit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.15,
        letterSpacing: -0.3,
      ),
      // SacredSectionTitle / Home's `_sectionTitle`.
      titleLarge: GoogleFonts.kanit(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: textColor,
        letterSpacing: -0.2,
      ),
      titleMedium: GoogleFonts.kanit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      titleSmall: GoogleFonts.kanit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.kanit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.kanit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: GoogleFonts.kanit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      labelLarge: GoogleFonts.kanit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: GoogleFonts.kanit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      // Editorial uppercase overline fallback (SacredOverline normally uses
      // SacredText.display directly; this gives the theme slot a matching
      // size/weight/tracking for any Kanit-based overline usage).
      labelSmall: GoogleFonts.kanit(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 2.6,
      ),
    );
  }
} 