import 'package:flutter/material.dart';

/// Palet warna utama sesuai referensi (Emerald-Teal-Mint & Pearl White)
class AppColors {
  AppColors._();

  // Warna Utama (Dark & Light Shared)
  static const Color emeraldDark = Color(0xFF0C342C); // Hijau gelap mewah (#0C342C)
  static const Color emeraldDeep = Color(0xFF076653); // Hijau zamrud menengah (#076653)[cite: 1]
  static const Color accentMint  = Color(0xFFE3EF26); // Aksen mint neon segar (#E3EF26)[cite: 1]
  static const Color tealGlow    = Color(0xFF00B894); // Aksen tambahan untuk indikator
  static const Color neutral     = Color(0xFF6B7F75); // Abu kehijauan netral (teks sekunder/ikon/status netral)

  // Varian Mode Terang (Light Theme)
  static const Color lightBg          = Color(0xFFF4F7F5); // Putih mutiara kehijauan yang lembut
  static const Color lightSurface     = Colors.white;
  static const Color lightTextPrimary = Color(0xFF102217);
  static const Color lightCardBorder  = Color(0xFFE2EFE6);

  // Varian Mode Gelap (Dark Theme)
  static const Color darkBg           = Color(0xFF061A14); // Latar belakang gelap pekat elegan
  static const Color darkSurface      = Color(0xFF0F2D24); // Permukaan kartu gelap semi-transparan
  static const Color darkTextPrimary  = Color(0xFFF2F7F4);
  static const Color darkCardBorder   = Color(0xFF1B4D3E);
}

/// Tema Terang (Light Theme) yang Aesthetic & Bersih
ThemeData buildLightAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Segoe UI',
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.emeraldDeep,
      primary: AppColors.emeraldDark,
      secondary: AppColors.tealGlow,
      surface: AppColors.lightSurface,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.emeraldDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.6,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 6,
      shadowColor: AppColors.emeraldDark.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.lightCardBorder, width: 1.2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.lightCardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.lightCardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.emeraldDeep, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.emeraldDark,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        elevation: 6,
        shadowColor: AppColors.emeraldDark.withValues(alpha: 0.3),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1),
      ),
    ),
  );
}

/// Tema Gelap (Dark Theme) ala Referensi UI Modern
ThemeData buildDarkAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Segoe UI',
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.emeraldDeep,
      primary: AppColors.accentMint,
      secondary: AppColors.tealGlow,
      surface: AppColors.darkSurface,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 0.6,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.darkCardBorder, width: 1.2),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.darkCardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.darkCardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.accentMint, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accentMint,
        foregroundColor: AppColors.emeraldDark,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        elevation: 8,
        shadowColor: AppColors.accentMint.withValues(alpha: 0.3),
        textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
      ),
    ),
  );
}