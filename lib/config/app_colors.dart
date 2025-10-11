import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors - Blue Grey Theme
  static const Color lightPrimary = Color(0xFF455A64); // Blue Grey 700
  static const Color lightSecondary = Color(0xFF607D8B); // Blue Grey 500
  static const Color lightAccent = Color(0xFF00BCD4); // Cyan accent
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Colors.white;
  static const Color lightOnPrimary = Colors.white;
  static const Color lightOnSecondary = Colors.white;
  static const Color lightOnBackground = Color(0xFF263238);
  static const Color lightOnSurface = Color(0xFF263238);

  // Dark Theme Colors - Blue Grey Theme
  static const Color darkPrimary = Color(0xFF607D8B); // Blue Grey 500
  static const Color darkSecondary = Color(0xFF78909C); // Blue Grey 400
  static const Color darkAccent = Color(0xFF26C6DA); // Cyan accent light
  static const Color darkBackground = Color(0xFF263238); // Blue Grey 900
  static const Color darkSurface = Color(0xFF37474F); // Blue Grey 800
  static const Color darkOnPrimary = Colors.white;
  static const Color darkOnSecondary = Colors.white;
  static const Color darkOnBackground = Color(0xFFF8FAFC);
  static const Color darkOnSurface = Color(0xFFF8FAFC);

  // Legacy colors for backward compatibility
  static const Color primary = lightPrimary;
  static const Color accent = lightAccent;
  static const Color appBarColor = Colors.white;
  static const Color appBarBackground = lightPrimary;
}
