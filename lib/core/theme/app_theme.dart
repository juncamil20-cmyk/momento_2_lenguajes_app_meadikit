import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const display = 'Bebas Neue';
  static const body = 'DM Sans';
}

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.orange,
      onPrimary: AppColors.background,
      secondary: AppColors.cream,
      surface: AppColors.surface,
      onSurface: AppColors.cream,
      error: AppColors.danger,
    ),
    fontFamily: AppTypography.body,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: AppTypography.display,
        fontSize: 38,
        height: 1,
        color: AppColors.cream,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppTypography.display,
        fontSize: 30,
        height: 1.05,
        color: AppColors.cream,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.cream,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
      ),
      bodyLarge: TextStyle(fontSize: 15, height: 1.45, color: AppColors.cream),
      bodyMedium: TextStyle(fontSize: 13, height: 1.4, color: AppColors.cream),
      bodySmall: TextStyle(fontSize: 11, height: 1.35, color: AppColors.muted),
      labelLarge: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: .7,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.cream,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceRaised,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: AppColors.orange),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.background,
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: .7,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cream,
        minimumSize: const Size.fromHeight(46),
        side: const BorderSide(color: AppColors.border),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: .6,
        ),
      ),
    ),
    dividerColor: AppColors.border,
  );
}
