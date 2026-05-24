import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors
  static const Color background = Color(0xFFF8FAFC); // Slate 50 (Very soft, premium, clean background)
  static const Color surface = Color(0xFFFFFFFF); // Pure White

  // Containers
  static const Color surfaceContainerLow = Color(0xFFF1F5F9); // Slate 100 (Used for Inputs & soft detail containers)
  static const Color surfaceContainer = Color(0xFFFFFFFF); // Pure White (Makes cards look incredibly clean)
  static const Color surfaceContainerHigh = Color(0xFFFFFFFF); // Pure White (Bottom Nav & Stats Cards)
  
  // Brand Accents
  static const Color tertiary = Color(0xFF4F46E5); // Indigo 600 (Signature brand color)
  static const Color tertiaryContainer = Color(0xFFEEF2FF); // Indigo 50 (Pastel badge / avatar background)
  static const Color onTertiaryContainer = Color(0xFF4F46E5); // Indigo 600 text

  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color primaryContainer = Color(0xFFEFF6FF); // Blue 50
  
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color secondaryContainer = Color(0xFFF0FDF4); // Green 50 (Perfect soft success background)
  
  static const Color error = Color(0xFFE11D48); // Rose 600
  static const Color errorContainer = Color(0xFFFFF1F2); // Rose 50

  // Neutral texts
  static const Color onBackground = Color(0xFF0F172A); // Slate 900 (High contrast heading text)
  static const Color onSurface = Color(0xFF0F172A); // Slate 900
  static const Color onSurfaceVariant = Color(0xFF64748B); // Slate 500 (Clean, elegant subtitle text)
  
  // Borders & Dividers
  static const Color outline = Color(0xFF94A3B8); // Slate 400 (Hint text & secondary borders)
  static const Color outlineVariant = Color(0xFFE2E8F0); // Slate 200 (Clean subtle card borders)

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      fontFamily: 'Geist',
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: onBackground),
        titleTextStyle: TextStyle(
          color: onBackground,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: const ColorScheme.light(
        background: background,
        surface: surface,
        primary: tertiary,
        onPrimary: Colors.white,
        secondary: secondary,
        error: error,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: tertiary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: outline, fontSize: 14),
        labelStyle: const TextStyle(color: onSurfaceVariant, fontSize: 14),
        prefixIconColor: outline,
        suffixIconColor: outline,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tertiary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
