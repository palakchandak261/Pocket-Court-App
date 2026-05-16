import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const indigo = Color(0xFF3F51B5);
  static const indigoDark = Color(0xFF283593);
  static const indigoLight = Color(0xFF7986CB);
  static const amber = Color(0xFFFFC107);
  static const amberDark = Color(0xFFFFA000);
  static const surface = Color(0xFFF5F6FA);

  // Per-category gradient pairs
  static const List<List<Color>> categoryGradients = [
    [Color(0xFF3F51B5), Color(0xFF7986CB)],
    [Color(0xFF00897B), Color(0xFF4DB6AC)],
    [Color(0xFFE53935), Color(0xFFEF9A9A)],
    [Color(0xFF8E24AA), Color(0xFFCE93D8)],
    [Color(0xFFF4511E), Color(0xFFFFAB91)],
    [Color(0xFF039BE5), Color(0xFF81D4FA)],
    [Color(0xFF43A047), Color(0xFFA5D6A7)],
    [Color(0xFF6D4C41), Color(0xFFBCAAA4)],
  ];

  static ThemeData get theme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: indigo,
        primary: indigo,
        secondary: amber,
        brightness: brightness,
        surface: isDark ? const Color(0xFF1A1A2E) : surface,
      ),
      scaffoldBackgroundColor: isDark ? const Color(0xFF1A1A2E) : surface,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: indigo,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: indigoDark,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: indigo,
        unselectedItemColor: Color(0xFFBDBDBD),
        elevation: 12,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: amber,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      dividerTheme:
          const DividerThemeData(color: Color(0xFFEEEEEE), thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: indigo, width: 1.5),
        ),
      ),
    );
  }
}
