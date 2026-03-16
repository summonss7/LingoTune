import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _themeColorName = 'default';
  Color _seedColorValue = Colors.deepPurple;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  Color get seedColor => _seedColorValue;

  Color _getSeedColor(String colorName) {
    switch (colorName) {
      case 'purple':
        return Colors.purple;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'pink':
        return Colors.pink;
      case 'deepOrange':
        return Colors.deepOrange;
      case 'darkRed':
        return const Color(0xFF8B0000);
      case 'teal':
        return Colors.teal;
      case 'cyan':
        return Colors.cyan;
      case 'amber':
        return Colors.amber;
      case 'lime':
        return Colors.lime;
      default:
        return Colors.deepPurple;
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeColorName = prefs.getString('themeColor') ?? 'default';
    _seedColorValue = _getSeedColor(_themeColorName);
    notifyListeners();
  }

  Future<void> setIsDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    _isDarkMode = value;
    notifyListeners();
  }

  Future<void> setThemeColor(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeColor', value);
    _themeColorName = value;
    _seedColorValue = _getSeedColor(value);
    notifyListeners();
  }

  Future<String> getThemeColor() async {
    return _themeColorName;
  }
}
