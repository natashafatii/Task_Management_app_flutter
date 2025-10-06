import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      elevation: 2,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondary,
    ),
    cardColor: AppColors.surface,
    iconTheme: const IconThemeData(color: AppColors.iconPrimary),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.textPrimary),
      titleLarge: TextStyle(color: AppColors.textPrimary),
      titleMedium: TextStyle(color: AppColors.textPrimary),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
      labelLarge: TextStyle(color: AppColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(color: AppColors.textSecondary),
      labelStyle: const TextStyle(color: AppColors.textPrimary),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.secondary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Color.lerp(AppColors.secondary, AppColors.surface, 0.3) ?? AppColors.secondary,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),

    // Button themes for authentication screens
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 2,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textLight,
      onError: AppColors.textLight,
      surfaceTint: Colors.transparent, // Replaces background in newer versions
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      outline: AppColors.outline,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.surfaceDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textLight),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.textLight,
    ),
    cardColor: AppColors.surfaceDark,
    iconTheme: const IconThemeData(color: AppColors.textLight),

    // TextTheme
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.textDarkPrimary),
      displaySmall: TextStyle(color: AppColors.textDarkPrimary),
      headlineLarge: TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.textDarkPrimary),
      headlineSmall: TextStyle(color: AppColors.textDarkPrimary),
      titleLarge: TextStyle(color: AppColors.textDarkPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.textDarkPrimary),
      titleSmall: TextStyle(color: AppColors.textDarkPrimary),
      bodyLarge: TextStyle(color: AppColors.textDarkPrimary),
      bodyMedium: TextStyle(color: AppColors.textDarkPrimary),
      bodySmall: TextStyle(color: AppColors.textDarkSecondary),
      labelLarge: TextStyle(color: AppColors.textDarkPrimary),
      labelMedium: TextStyle(color: AppColors.textDarkPrimary),
      labelSmall: TextStyle(color: AppColors.textDarkSecondary),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      hintStyle: const TextStyle(color: AppColors.textDarkSecondary),
      labelStyle: const TextStyle(color: AppColors.textDarkPrimary),
      floatingLabelStyle: const TextStyle(color: AppColors.secondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),

    // Dialog theme - FIXED: Use DialogThemeData instead of DialogTheme
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surfaceDark,
      titleTextStyle: TextStyle(color: AppColors.textDarkPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: AppColors.textDarkPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),

    // Button themes for authentication screens
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.textLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 2,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryContainer,
        side: const BorderSide(color: AppColors.primaryContainer),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryContainer,
      ),
    ),

    // Checkbox theme for Terms & Conditions - FIXED: Use WidgetStateProperty instead of MaterialStateProperty
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryDark;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.textLight),
      side: const BorderSide(color: AppColors.textDarkSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 1,
      space: 1,
    ),

    // Color scheme - FIXED: Remove deprecated 'background' property
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: AppColors.textLight,
      onSecondary: AppColors.textLight,
      onSurface: AppColors.textDarkPrimary,
      onError: AppColors.textLight,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      surfaceVariant: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      surfaceTint: Colors.transparent, // Added to replace background
    ),
  );
}