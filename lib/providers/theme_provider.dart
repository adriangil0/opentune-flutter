import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_loadThemeMode());

  static ThemeMode _loadThemeMode() {
    final box = Hive.box('settings');
    final value = box.get('themeMode', defaultValue: 'system');
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final box = Hive.box('settings');
    switch (mode) {
      case ThemeMode.light: box.put('themeMode', 'light'); break;
      case ThemeMode.dark: box.put('themeMode', 'dark'); break;
      default: box.put('themeMode', 'system');
    }
  }
}

final seedColorProvider = StateNotifierProvider<SeedColorNotifier, Color>((ref) {
  return SeedColorNotifier();
});

class SeedColorNotifier extends StateNotifier<Color> {
  SeedColorNotifier() : super(_loadColor());

  static Color _loadColor() {
    final box = Hive.box('settings');
    final value = box.get('seedColor', defaultValue: 0xFF1DB954);
    return Color(value);
  }

  void setColor(Color color) {
    state = color;
    Hive.box('settings').put('seedColor', color.value);
  }
}
