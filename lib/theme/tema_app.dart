import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8B5E3C);
  static const Color primaryDark = Color(0xFF6B4226);
  static const Color primaryLight = Color(0xFFD4A574);
  static const Color accent = Color(0xFF4A9B8E);
  static const Color accentLight = Color(0xFFE8F5F3);
  static const Color background = Color(0xFFFFF8F3);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2C1810);
  static const Color textMedium = Color(0xFF6B4226);
  static const Color textLight = Color(0xFF9E7B5A);
  static const Color divider = Color(0xFFF0E6DC);
  static const Color categoryBg1 = Color(0xFFFFF3E8);
  static const Color categoryBg2 = Color(0xFFE8F4FF);
  static const Color categoryBg3 = Color(0xFFE8F5F3);
  static const Color categoryBg4 = Color(0xFFF3F0FF);
  static const Color gold = Color(0xFFC8922A);
  static const Color wishlist = Color(0xFFE57373);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          background: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.textDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Nunito',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          hintStyle: TextStyle(
            color: AppColors.textLight,
            fontSize: 14,
            fontFamily: 'Nunito',
          ),
        ),
      );
}
