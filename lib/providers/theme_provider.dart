import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _useGlassmorphism = true;

  ThemeMode get themeMode => _themeMode;
  bool get useGlassmorphism => _useGlassmorphism;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    _useGlassmorphism = prefs.getBool('useGlassmorphism') ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> toggleGlassmorphism() async {
    _useGlassmorphism = !_useGlassmorphism;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useGlassmorphism', _useGlassmorphism);
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1F2937),
        ),
        cardTheme: const CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF111827),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFF9FAFB),
        ),
        cardTheme: const CardThemeData(
    elevation: 0,
    color: Color(0xFF1F2937),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      );
}
