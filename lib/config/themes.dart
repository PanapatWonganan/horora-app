import 'package:flutter/material.dart';

// สีหลักของแอปพลิเคชัน
const Color kPrimaryColor = Color(0xFF6A1B9A);
const Color kSecondaryColor = Color(0xFF283593);
const Color kAccentColor = Color(0xFFFFD700);
const Color kBackgroundColor = Color(0xFF151030);
const Color kSurfaceColor = Color(0xFF1E1E2C);
const Color kTextColor = Color(0xFFF5F5F5);

// ธีมมืดสำหรับแอปพลิเคชัน
ThemeData darkTheme() {
  return ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      surface: kSurfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: kTextColor,
      tertiary: kAccentColor,
    ),
    useMaterial3: true,
    fontFamily: 'Kanit',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: kTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: kTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: kTextColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: kTextColor,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: kTextColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: kTextColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: kTextColor,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kSurfaceColor,
      foregroundColor: kTextColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: kSurfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimaryColor,
        side: const BorderSide(color: kPrimaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kSurfaceColor,
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
} 