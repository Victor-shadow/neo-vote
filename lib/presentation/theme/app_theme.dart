// lib/presentation/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:neo_vote/presentation/theme/pallete.dart';

class AppTheme {
  // --- Shared Input Decoration for both themes ---
  static final _inputDecorationTheme = InputDecorationTheme(
    contentPadding: const EdgeInsets.all(24),
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Palettes.primary, // Use the primary color for focus
        width: 2,
      ),
    ),
  );

  // --- Shared Elevated Button Style for both themes ---
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // --- Dark Theme Definition (using your Palettes directly) ---
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Palettes.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Palettes.background,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Palettes.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Palettes.textPrimary),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Palettes.primary,
      secondary: Palettes.secondary,
      surface: Palettes.surface,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Palettes.textPrimary,
      error: Palettes.error,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Roboto', // Or your preferred font
          bodyColor: Palettes.textSecondary,
          displayColor: Palettes.textPrimary,
        ),
    inputDecorationTheme: _inputDecorationTheme.copyWith(
      fillColor: Palettes.surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _elevatedButtonTheme.style?.copyWith(
        backgroundColor: WidgetStateProperty.all(Palettes.primary),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
  );

  // --- Light Theme Definition (derived from your primary colors) ---
  static ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFF5F7FA), // A very light grey
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F7FA),
      foregroundColor: Colors.black, // Ensures AppBar icons are visible
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Palettes.primary, // Keep the brand's primary blue
      secondary: Palettes.secondary,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      error: Palettes.error,
    ),
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Roboto', // Or your preferred font
          bodyColor: const Color(0xFF495057),
          displayColor: Colors.black,
        ),
    inputDecorationTheme: _inputDecorationTheme.copyWith(
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _elevatedButtonTheme.style?.copyWith(
        backgroundColor: WidgetStateProperty.all(Palettes.primary),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
    ),
  );
}
