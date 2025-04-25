import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF4CAF50); // Green color
  static const Color secondaryColor = Color(0xFF2E7D32); // Dark green
  static const Color accentColor = Color(0xFF8BC34A); // Light green
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light grey
  static const Color textColor = Color(0xFF212121); // Dark grey
  static const Color errorColor = Color(0xFFD32F2F); // Red

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
    );
  }
}
