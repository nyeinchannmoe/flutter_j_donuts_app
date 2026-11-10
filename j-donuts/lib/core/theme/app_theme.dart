import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jdonuts/core/theme/tokens/app_colors.dart';
import 'package:jdonuts/core/theme/tokens/app_icon_sizes.dart';
import 'package:jdonuts/core/theme/tokens/app_radius.dart';
import 'package:jdonuts/core/theme/tokens/app_shadows.dart';
import 'package:jdonuts/core/theme/tokens/app_spacing.dart';
import 'package:jdonuts/core/theme/tokens/app_typography.dart';

/// Builds the single app theme from the design tokens.
abstract final class AppTheme {
  static final SystemUiOverlayStyle lightSystemBars = _lightSystemBars();

  static SystemUiOverlayStyle _lightSystemBars() {
    final clear = AppColors.light.surface.withValues(
      alpha: 0,
      red: 0,
      green: 0,
      blue: 0,
    );
    return SystemUiOverlayStyle(
      statusBarColor: clear,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: clear,
      systemNavigationBarDividerColor: clear,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );
  }

  static ThemeData light() {
    const colors = AppColors.light;
    final typography = AppTypography.withColor(colors.textPrimary);
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      colorScheme: _colorScheme(colors),
      filledButtonTheme: FilledButtonThemeData(
        style: _primaryButton(colors, typography),
      ),
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
    shadow: AppShadows.standard.card.first.color,
    scrim: colors.scrim,
  );

  static ButtonStyle _primaryButton(
    AppColors colors,
    AppTypography typography,
  ) {
    const spacing = AppSpacing.standard;
    final clear = colors.surface.withValues(alpha: 0);
    return FilledButton.styleFrom(
      backgroundColor: colors.primary,
      disabledBackgroundColor: colors.textSecondary.withValues(alpha: 0.85),
      foregroundColor: colors.onPrimary,
      disabledForegroundColor: colors.onPrimary,
      overlayColor: clear,
      surfaceTintColor: clear,
      shadowColor: clear,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.standard.pillAll),
      minimumSize: Size.fromHeight(spacing.xxxl + spacing.xs),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xl,
        vertical: spacing.sm,
      ),
      textStyle: typography.button.copyWith(color: colors.onPrimary),
    );
  }

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
