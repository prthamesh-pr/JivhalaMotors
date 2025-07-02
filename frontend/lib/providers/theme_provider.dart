import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString('theme_mode');

      if (themeModeString != null) {
        switch (themeModeString) {
          case 'light':
            _themeMode = ThemeMode.light;
            _isDarkMode = false;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            _isDarkMode = true;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            _isDarkMode = _getSystemBrightness() == Brightness.dark;
            break;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;

      switch (mode) {
        case ThemeMode.light:
          _isDarkMode = false;
          break;
        case ThemeMode.dark:
          _isDarkMode = true;
          break;
        case ThemeMode.system:
          _isDarkMode = _getSystemBrightness() == Brightness.dark;
          break;
      }

      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.name);
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      // If system mode, toggle to opposite of current system setting
      final systemBrightness = _getSystemBrightness();
      setThemeMode(
        systemBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
      );
    }
  }

  Brightness _getSystemBrightness() {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  void updateSystemBrightness() {
    if (_themeMode == ThemeMode.system) {
      final newIsDark = _getSystemBrightness() == Brightness.dark;
      if (_isDarkMode != newIsDark) {
        _isDarkMode = newIsDark;
        notifyListeners();
      }
    }
  }
}
