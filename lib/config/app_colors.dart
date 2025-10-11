import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors - Yellow/Gold Theme (Matching Logo)
  static const Color lightPrimary = Color(0xFFFFD700); // Gold - matching logo
  static const Color lightSecondary = Color(0xFF1A1A1A); // Black - matching logo text
  static const Color lightAccent = Color(0xFFFFC107); // Amber accent
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Colors.white;
  static const Color lightOnPrimary = Color(0xFF1A1A1A); // Black text on gold
  static const Color lightOnSecondary = Colors.white; // White text on black
  static const Color lightOnBackground = Color(0xFF1A1A1A);
  static const Color lightOnSurface = Color(0xFF1A1A1A);

  // Dark Theme Colors - Yellow/Gold Theme (Matching Logo)
  static const Color darkPrimary = Color(0xFFFFD700); // Gold
  static const Color darkSecondary = Color(0xFF2A2A2A); // Dark grey
  static const Color darkAccent = Color(0xFFFFC107); // Amber accent
  static const Color darkBackground = Color(0xFF121212); // Dark background
  static const Color darkSurface = Color(0xFF1E1E1E); // Dark surface
  static const Color darkOnPrimary = Color(0xFF1A1A1A); // Black text on gold
  static const Color darkOnSecondary = Color(0xFFFFD700); // Gold text on dark
  static const Color darkOnBackground = Color(0xFFF8FAFC);
  static const Color darkOnSurface = Color(0xFFF8FAFC);

  // Legacy colors for backward compatibility
  static const Color primary = lightPrimary;
  static const Color accent = lightAccent;
  static const Color appBarColor = Color(0xFF1A1A1A);
  static const Color appBarBackground = lightPrimary;
}
