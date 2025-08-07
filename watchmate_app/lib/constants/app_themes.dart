import 'package:flutter/material.dart';

class AppColors {
  static const lightPrimary = Color(0xFF1189EA);
  static const darkPrimary = Color(0xFF1189EA);

  static const lightBackground = Color(0xFFFFFFFF);
  static const darkBackground = Color(0xFF0F172A);

  static const lightCard = Color(0xFFF6F6F6);
  static const darkCard = Color(0xFF1E293B);

  static const lightText = Colors.black;
  static const darkText = Color(0xFFE2E8F0);

  static const lightHint = Color(0xFF797979);
  static const darkHint = Color(0xFF94A3B8);

  static const success = Color(0xFF2ECC71);
  static const error = Color(0xFFF87171);

  static const shimmerBase = Color(0xFF64748B);
  static final shimmerHighlight = shimmerBase.withValues(alpha: 0.3);
  static final shimmerLowlight = shimmerBase.withValues(alpha: 0.2);

  static const lightBorder = Color(0xFFE0E0E0);
  static const darkBorder = Color(0xFF334155);

  static const pageTransition = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );
}

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.lightBackground,
    // pageTransitionsTheme: AppColors.pageTransition,
    primaryColor: AppColors.lightPrimary,
    cardColor: AppColors.lightCard,
    brightness: Brightness.light,
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
    scaffoldBackgroundColor: AppColors.darkBackground,
    // pageTransitionsTheme: AppColors.pageTransition,
    primaryColor: AppColors.darkPrimary,
    cardColor: AppColors.darkCard,
    brightness: Brightness.dark,
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
