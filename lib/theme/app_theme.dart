import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const ink = Color(0xFF202331);
  static const mutedInk = Color(0xFF6E7180);
  static const paper = Color(0xFFF8F7F3);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFE8E6DF);
  static const indigo = Color(0xFF5367D9);
  static const indigoDark = Color(0xFF3546A4);
  static const coral = Color(0xFFF08E79);
  static const mint = Color(0xFF74B7A5);
  static const mustard = Color(0xFFE7B655);
  static const lavender = Color(0xFF9A83C9);

  static const noteColors = <String, Color>{
    'indigo': indigo,
    'coral': coral,
    'mint': mint,
    'mustard': mustard,
    'lavender': lavender,
  };

  static Color noteColor(String key) => noteColors[key] ?? indigo;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.indigo,
      brightness: Brightness.light,
      surface: AppColors.paper,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: AppColors.indigo,
        onPrimary: Colors.white,
        surface: AppColors.paper,
        onSurface: AppColors.ink,
        outline: AppColors.line,
      ),
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: 'Arial',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.indigo, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paper,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        labelStyle: const TextStyle(
          color: AppColors.mutedInk,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppColors.ink,
          fontSize: 38,
          fontWeight: FontWeight.w800,
          height: 1.1,
        ),
        headlineSmall: TextStyle(
          color: AppColors.ink,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(
          color: AppColors.mutedInk,
          fontSize: 14,
          height: 1.45,
        ),
      ),
    );
  }
}
