import 'package:flutter/material.dart';

class AppColors {
  // Base
  // static const Color lightPrimary = Color(0xFF6D53F4);
  static const Color lightPrimary = Color(0xFFFF3B30);
  static const Color darkPrimary = Color(0xFF3B82F6);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF0F172A);

  static const Color lightCard = Color(0xFFF6F6F6);
  static const Color darkCard = Color(0xFF1E293B);

  static const Color lightText = Colors.black;
  static const Color darkText = Color(0xFFE2E8F0);

  static const Color lightHint = Color(0xFF797979);
  static const Color darkHint = Color(0xFF94A3B8);

  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFF87171);

  static const Color shimmerBase = Color(0xFF64748B);
  static final Color shimmerHighlight = shimmerBase.withValues(alpha: 0.3);
  static final Color shimmerLowlight = shimmerBase.withValues(alpha: 0.2);

  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color darkBorder = Color(0xFF334155);
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.lightPrimary,
    cardColor: AppColors.lightCard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightText,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.lightHint),
      bodyLarge: TextStyle(color: AppColors.lightText),
    ),
    hintColor: AppColors.lightHint,
    colorScheme: const ColorScheme.light(
      surface: AppColors.lightBackground,
      primary: AppColors.lightPrimary,
      onSurface: AppColors.lightText,
      onPrimary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    primaryColor: AppColors.darkPrimary,
    cardColor: AppColors.darkCard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkText,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.darkHint),
      bodyLarge: TextStyle(color: AppColors.darkText),
    ),
    hintColor: AppColors.darkHint,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onSurface: AppColors.darkText,
      surface: AppColors.darkCard,
      onPrimary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
    ),
  );
}
