import 'package:flutter/material.dart';

class AppPalette {
  static const Color navy = Color(0xFF0F2D5C);
  static const Color navyDark = Color(0xFF0A2248);
  static const Color cyan = Color(0xFF57E4FF);
  static const Color cyanSoft = Color(0xFF94EEFF);
  static const Color button = Color(0xFF6F69EA);
  static const Color textPrimary = Color(0xFFF7FAFF);
  static const Color textSecondary = Color(0xFF3D8EC6);
  static const Color success = Color(0xFF4AD3A3);
  static const Color danger = Color(0xFFFF6684);
}

class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppPalette.navy,
      colorScheme: const ColorScheme.dark(
        primary: AppPalette.cyan,
        secondary: AppPalette.button,
        surface: AppPalette.navyDark,
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
        headlineMedium: TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppPalette.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: AppPalette.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.button,
          foregroundColor: AppPalette.textPrimary,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 30,
            letterSpacing: 0.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          minimumSize: const Size(180, 70),
        ),
      ),
    );
  }
}
