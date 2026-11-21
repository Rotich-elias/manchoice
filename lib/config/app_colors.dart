import 'package:flutter/material.dart';

/// Brand colours and semantic tokens used throughout the app.
///
/// The palette is built around the MansChoice gold/charcoal identity:
/// - [gold] is the bright brand highlight (logo ring, focus, gradients).
/// - [goldPrimary] is the accessible deep gold used for text and buttons so
///   headings/icons stay legible on light surfaces (WCAG AA, 5.2:1).
/// - [ink] provides structure; semantic colours stay consistent across screens.
class AppColors {
  // Core brand palette
  static const Color gold = Color(0xFFF5C518);
  static const Color goldDeep = Color(0xFF8A6800);
  static const Color goldPrimary = Color(0xFF8A6800);
  static const Color goldSoft = Color(0xFFFFF7D6);
  static const Color ink = Color(0xFF161616);
  static const Color inkSoft = Color(0xFF2E2E2E);
  static const Color canvas = Color(0xFFF6F5F2);
  static const Color line = Color(0xFFE4E1D8);

  // Harmonised menu accents (distinct but within the brand family)
  static const Color menuLoans = Color(0xFF8A6800);
  static const Color menuPayments = Color(0xFF2E7D32);
  static const Color menuProducts = Color(0xFF1565C0);
  static const Color menuSupport = Color(0xFF37474F);

  // Semantic status colours
  static const Color success = Color(0xFF2E7D32);
  static const Color successDark = Color(0xFF1B5E20);
  static const Color warning = Color(0xFFEF6C00);
  static const Color warningDark = Color(0xFFE65100);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerDark = Color(0xFF8E0000);
  static const Color info = Color(0xFF1565C0);

  // Light theme tokens
  static const Color lightPrimary = goldPrimary;
  static const Color lightSecondary = ink;
  static const Color lightAccent = goldPrimary;
  static const Color lightBackground = canvas;
  static const Color lightSurface = Colors.white;
  static const Color lightOnPrimary = Colors.white;
  static const Color lightOnSecondary = Colors.white;
  static const Color lightOnBackground = ink;
  static const Color lightOnSurface = ink;

  // Dark theme tokens
  static const Color darkPrimary = gold;
  static const Color darkSecondary = Color(0xFF2A2A2A);
  static const Color darkAccent = gold;
  static const Color darkBackground = Color(0xFF101010);
  static const Color darkSurface = Color(0xFF1C1C1C);
  static const Color darkOnPrimary = ink;
  static const Color darkOnSecondary = gold;
  static const Color darkOnBackground = Color(0xFFF5F5F5);
  static const Color darkOnSurface = Color(0xFFF5F5F5);

  // Legacy aliases kept for backwards compatibility with older screens.
  static const Color primary = lightPrimary;
  static const Color accent = lightAccent;
  static const Color appBarColor = ink;
  static const Color appBarBackground = gold;
}
