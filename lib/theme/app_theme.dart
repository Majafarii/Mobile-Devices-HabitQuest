import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Shared Material 3 visual defaults. Screen-specific styling belongs in screens.
abstract final class AppTheme {
  static const cardRadius = 20.0;

  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.pink,
      onPrimary: AppColors.surface,
      primaryContainer: Color(0xFFFFE5EB),
      onPrimaryContainer: AppColors.primaryText,
      secondary: AppColors.information,
      onSecondary: AppColors.surface,
      secondaryContainer: Color(0xFFE5F0FF),
      onSecondaryContainer: AppColors.primaryText,
      tertiary: AppColors.streak,
      onTertiary: AppColors.primaryText,
      error: Color(0xFFFF3B30),
      onError: AppColors.surface,
      surface: AppColors.surface,
      onSurface: AppColors.primaryText,
      surfaceContainerHighest: AppColors.background,
      onSurfaceVariant: AppColors.secondaryText,
      outline: Color(0xFFD2D2D7),
      outlineVariant: Color(0xFFE5E5EA),
      shadow: Color(0x14000000),
      scrim: Color(0x52000000),
      inverseSurface: AppColors.primaryText,
      onInverseSurface: AppColors.surface,
      inversePrimary: Color(0xFFFFA3B5),
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.display,
      displayMedium: AppTextStyles.headline,
      displaySmall: AppTextStyles.headline,
      headlineLarge: AppTextStyles.headline,
      headlineMedium: AppTextStyles.headline,
      headlineSmall: AppTextStyles.title,
      titleLarge: AppTextStyles.title,
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      bodyLarge: AppTextStyles.body,
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
        color: AppColors.primaryText,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.35,
        color: AppColors.secondaryText,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
      labelMedium: AppTextStyles.label,
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.primaryText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.title,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: const Color(0xFFFFE5EB),
      elevation: 0,
      labelTextStyle: const WidgetStatePropertyAll(AppTextStyles.label),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.pink,
        foregroundColor: AppColors.surface,
        textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.pink,
      onPrimary: AppColors.surface,
      primaryContainer: AppColors.darkPinkContainer,
      onPrimaryContainer: AppColors.darkPrimaryText,
      secondary: AppColors.information,
      onSecondary: AppColors.surface,
      secondaryContainer: Color(0xFF153A6B),
      onSecondaryContainer: AppColors.darkPrimaryText,
      tertiary: AppColors.streak,
      onTertiary: AppColors.primaryText,
      error: Color(0xFFFF453A),
      onError: AppColors.surface,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkPrimaryText,
      surfaceContainerHighest: AppColors.darkBackground,
      onSurfaceVariant: AppColors.darkSecondaryText,
      outline: Color(0xFF626267),
      outlineVariant: Color(0xFF414145),
      shadow: Color(0x33000000),
      scrim: Color(0x66000000),
      inverseSurface: AppColors.darkPrimaryText,
      onInverseSurface: AppColors.darkBackground,
      inversePrimary: Color(0xFFFFA3B5),
    ),
    textTheme: light.textTheme
        .apply(
          bodyColor: AppColors.darkPrimaryText,
          displayColor: AppColors.darkPrimaryText,
        )
        .copyWith(
          bodySmall: light.textTheme.bodySmall?.copyWith(
            color: AppColors.darkSecondaryText,
          ),
          labelMedium: AppTextStyles.label.copyWith(
            color: AppColors.darkSecondaryText,
          ),
          labelSmall: light.textTheme.labelSmall?.copyWith(
            color: AppColors.darkSecondaryText,
          ),
        ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkPrimaryText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.title.copyWith(
        color: AppColors.darkPrimaryText,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.darkPinkContainer,
      elevation: 0,
      labelTextStyle: WidgetStatePropertyAll(
        AppTextStyles.label.copyWith(color: AppColors.darkSecondaryText),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.pink,
        foregroundColor: AppColors.surface,
        textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
  );
}
