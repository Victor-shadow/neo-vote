// lib/presentation/theme/theme_provider.dart

import 'package:flutter/material.dart';
// CORRECTED: Use modern Riverpod import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/legacy.dart';
/// The key used to store the theme preference in SharedPreferences.
const String _themePrefsKey = 'app_theme_mode';

/// A StateNotifier that manages and persists the application's theme mode.
///
/// It loads the saved theme on initialization and saves it whenever it changes.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Loads the saved theme from local storage. Defaults to system theme if none is saved.
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(_themePrefsKey);
      if (themeName == 'dark') {
        state = ThemeMode.dark;
      } else if (themeName == 'light') {
        state = ThemeMode.light;
      } else {
        state = ThemeMode.system;
      }
    } catch (e) {
      // If prefs fail, default to system
      state = ThemeMode.system;
    }
  }

  /// Sets the new theme mode and persists it to local storage.
  Future<void> setTheme(ThemeMode newTheme) async {
    // Do nothing if the theme is already the same.
    if (state == newTheme) return;

    state = newTheme;

    try {
      // Save the new theme preference.
      final prefs = await SharedPreferences.getInstance();
      if (newTheme == ThemeMode.system) {
        await prefs.remove(_themePrefsKey);
      } else {
        await prefs.setString(_themePrefsKey, newTheme.name);
      }
    } catch (e) {
      // Handle potential errors with shared_preferences
      debugPrint("Could not save theme: $e");
    }
  }
}

/// The provider that exposes the [ThemeNotifier] to the rest of the app.
///
/// The UI will watch this provider to react to theme changes.
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
      (ref) => ThemeNotifier(),
);
