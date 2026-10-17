import 'package:flutter/material.dart';

class AppColors {
  static const cream = Color(0xFFFDFBF7);
  static const terracotta = Color(0xFFC9795B);
  static const olive = Color(0xFF7D8461);
  static const wood = Color(0xFF5C4332);
  static const sepiaDark = Color(0xFF2A211B);
  static const sepiaCard = Color(0xFF3A2E26);
}

class AppTheme {
  static TextTheme _text(Color color) => TextTheme(
        displayLarge: TextStyle(fontFamily: 'serif', fontSize: 32, color: color),
        headlineMedium:
            TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.w600, color: color),
        titleMedium:
            TextStyle(fontFamily: 'serif', fontSize: 17, fontWeight: FontWeight.w600, color: color),
        bodyLarge: TextStyle(fontSize: 16, height: 1.6, color: color),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: color),
      );

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.terracotta,
          primary: AppColors.terracotta,
          secondary: AppColors.olive,
          surface: Colors.white,
        ),
        textTheme: _text(AppColors.wood),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.wood.withOpacity(0.08)),
          ),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.sepiaDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.terracotta,
          brightness: Brightness.dark,
          surface: AppColors.sepiaCard,
        ),
        textTheme: _text(const Color(0xFFEADFD0)),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.sepiaCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
}
