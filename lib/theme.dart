import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF1A1A2E);
  static const foreground = Color(0xFFF0F0F5);
  static const card = Color(0xFF262640);
  static const cardForeground = Color(0xFFF0F0F5);
  static const primary = Color(0xFFE07828);
  static const primaryForeground = Color(0xFF1A0E05);
  static const secondary = Color(0xFF33334A);
  static const secondaryForeground = Color(0xFFE0E0E8);
  static const muted = Color(0xFF2E2E44);
  static const mutedForeground = Color(0xFF9A9AB0);
  static const accent = Color(0xFF32324A);
  static const accentForeground = Color(0xFFF5F5FA);
  static const destructive = Color(0xFFD43838);
  static const destructiveForeground = Color(0xFFFAFAFC);
  static const border = Color(0xFF404058);
  static const input = Color(0xFF4A4A62);
  static const ring = Color(0xFFE07828);
  static const success = Color(0xFF3DAF6C);
  static const successForeground = Color(0xFF0E2818);
  static const successSoft = Color(0xFF1E3A2A);
  static const info = Color(0xFF4A90D9);
  static const infoSoft = Color(0xFF1E2A3A);
  static const warning = Color(0xFFE0A820);
  static const warningSoft = Color(0xFF3A3020);
  static const codeBg = Color(0xFFF5F5FA);
  static const codeForeground = Color(0xFF202030);
  static const camera = Color(0xFF141420);
  static const cameraForeground = Color(0xFFCCC8E0);
  static const overlay = Color(0xB30D0D18);
  static const shadow = Color(0x40000000);
}

class AppTheme {
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.ibmPlexSansArabicTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.secondaryForeground,
        surface: AppColors.card,
        onSurface: AppColors.cardForeground,
        error: AppColors.destructive,
        onError: AppColors.destructiveForeground,
        outline: AppColors.border,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.ibmPlexSansArabic(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.foreground,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mutedForeground,
          textStyle: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.ibmPlexSansArabic(
          color: AppColors.mutedForeground,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.ibmPlexSansArabic(
          color: AppColors.mutedForeground,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.success,
        contentTextStyle: GoogleFonts.ibmPlexSansArabic(
          color: AppColors.successForeground,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        elevation: 2,
      ),
    );
  }
}
