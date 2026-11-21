import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shared visual language for MansChoice.
///
/// A restrained charcoal header, gold call-to-action buttons and soft,
/// rounded surfaces give the app a consistent premium feel in both themes.
class AppTheme {
  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: AppColors.gold,
          onPrimary: AppColors.ink,
          secondary: AppColors.ink,
          onSecondary: Colors.white,
          tertiary: AppColors.goldDeep,
          onTertiary: Colors.white,
          surface: AppColors.lightSurface,
          onSurface: AppColors.ink,
          onSurfaceVariant: Color(0xFF666666),
          surfaceContainerHighest: Color(0xFFF0EEE8),
          outline: AppColors.line,
          error: AppColors.danger,
          onError: Colors.white,
        ),
        scaffoldBackground: AppColors.lightBackground,
        cardColor: AppColors.lightSurface,
        borderColor: AppColors.line,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.gold,
          onPrimary: AppColors.ink,
          secondary: AppColors.gold,
          onSecondary: AppColors.ink,
          tertiary: AppColors.gold,
          onTertiary: AppColors.ink,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkOnSurface,
          onSurfaceVariant: Color(0xFFB0B0B0),
          surfaceContainerHighest: Color(0xFF262626),
          outline: Color(0xFF3A3A3A),
          error: Color(0xFFEF5350),
          onError: Colors.white,
        ),
        scaffoldBackground: AppColors.darkBackground,
        cardColor: AppColors.darkSurface,
        borderColor: const Color(0xFF333333),
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color borderColor,
  }) {
    final isDark = brightness == Brightness.dark;
    final textTheme = _textTheme(isDark ? Colors.white : AppColors.ink);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: scaffoldBackground,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Roboto',
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.ink,
        foregroundColor: isDark ? AppColors.gold : Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Colors.black26,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.gold : Colors.white,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.gold : Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.35),
          disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.tertiary,
          side: BorderSide(color: colorScheme.tertiary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.tertiary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF242424) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(
          color: colorScheme.tertiary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: colorScheme.tertiary,
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withValues(alpha: 0.2),
        circularTrackColor: colorScheme.primary.withValues(alpha: 0.2),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color color) => TextTheme(
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: -0.5,
        ),
        headlineSmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: color,
        ),
        titleSmall: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: color, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, color: color, height: 1.4),
        bodySmall: TextStyle(fontSize: 12, color: color, height: 1.35),
      );
}
