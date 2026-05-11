import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides light/dark theme switching with persistence.
/// Initial theme is loaded synchronously via [initialThemeMode] factory.
class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_mode';
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// Create with a pre-loaded theme mode to prevent flash.
  ThemeProvider({ThemeMode initialMode = ThemeMode.dark})
      : _themeMode = initialMode;

  /// Pre-load saved theme from SharedPreferences before creating the provider.
  /// Call this in main() before runApp to avoid theme flash.
  static Future<ThemeMode> loadSavedThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_key) ?? 'dark';
    return mode == 'light' ? ThemeMode.light : ThemeMode.dark;
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, _themeMode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
