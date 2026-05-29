import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFE87722);        // Orange utama
  static const Color primaryDark = Color(0xFFC45E0A);    // Orange gelap
  static const Color primaryLight = Color(0xFFFFD4A8);   // Orange muda
  static const Color accent = Color(0xFF4A9B8E);
  static const Color accentLight = Color(0xFFE8F5F3);
  static const Color background = Color(0xFFF5F5F5);     // Abu-abu muda
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);       // Hitam
  static const Color textMedium = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF9E9E9E);      // Abu-abu
  static const Color divider = Color(0xFFEEEEEE);
  static const Color categoryBg1 = Color(0xFFFFF3E8);    // Orange muda
  static const Color categoryBg2 = Color(0xFFE8F4FF);
  static const Color categoryBg3 = Color(0xFFE8F5F3);
  static const Color categoryBg4 = Color(0xFFFFF3E8);
  static const Color gold = Color(0xFFE87722);           // Sama dengan primary
  static const Color wishlist = Color(0xFFE57373);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.robotoTextTheme(),
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.background,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
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
             textStyle: GoogleFonts.roboto(  // ← ganti ini
              fontSize: 16,
              fontWeight: FontWeight.w700,

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
          hintStyle: GoogleFonts.roboto(  
            color: AppColors.textLight,
            fontSize: 14,
          ),
        ),
      );
}