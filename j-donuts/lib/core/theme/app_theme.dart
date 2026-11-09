import 'package:flutter/material.dart';
import 'package:jdonuts/core/theme/app_palette.dart';
import 'package:jdonuts/core/theme/tokens/app_colors.dart';
import 'package:jdonuts/core/theme/tokens/app_icon_sizes.dart';
import 'package:jdonuts/core/theme/tokens/app_radius.dart';
import 'package:jdonuts/core/theme/tokens/app_shadows.dart';
import 'package:jdonuts/core/theme/tokens/app_spacing.dart';
import 'package:jdonuts/core/theme/tokens/app_typography.dart';

/// Builds the single app theme from the design tokens.
abstract final class AppTheme {
  static ThemeData light() {
    const colors = AppColors.light;
    final typography = AppTypography.withColor(colors.textPrimary);
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      colorScheme: _colorScheme(colors),
      scaffoldBackgroundColor: colors.background,
      splashFactory: InkSparkle.splashFactory,
      textTheme: _textTheme(typography),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.textPrimary,
        contentTextStyle: typography.body.copyWith(color: colors.surface),
      ),
      extensions: [
        colors,
        typography,
        AppSpacing.standard,
        AppRadius.standard,
        AppShadows.standard,
        AppIconSizes.standard,
      ],
    );
  }

  static ColorScheme _colorScheme(AppColors colors) => ColorScheme.fromSeed(
    seedColor: colors.primary,
    primary: colors.primary,
    onPrimary: colors.onPrimary,
    secondary: colors.accent,
    tertiary: colors.highlight,
    surface: colors.surface,
    error: colors.danger,
    shadow: AppPalette.shadow,
    scrim: AppPalette.scrim,
  );

  static TextTheme _textTheme(AppTypography typography) => TextTheme(
    displaySmall: typography.display,
    headlineSmall: typography.headline,
    titleLarge: typography.title,
    titleMedium: typography.subtitle,
    bodyMedium: typography.body,
    bodySmall: typography.caption,
    labelLarge: typography.button,
    labelMedium: typography.label,
  );
}
