import 'package:flutter/material.dart';
import 'package:jdonuts/core/responsive/layout_metrics.dart';
import 'package:jdonuts/core/theme/tokens/app_colors.dart';
import 'package:jdonuts/core/theme/tokens/app_icon_sizes.dart';
import 'package:jdonuts/core/theme/tokens/app_radius.dart';
import 'package:jdonuts/core/theme/tokens/app_shadows.dart';
import 'package:jdonuts/core/theme/tokens/app_spacing.dart';
import 'package:jdonuts/core/theme/tokens/app_typography.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';

/// Shorthand access to localization, tokens and layout metrics.
extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;

  AppRadius get radius => Theme.of(this).extension<AppRadius>()!;

  AppTypography get typography => Theme.of(this).extension<AppTypography>()!;

  AppShadows get shadows => Theme.of(this).extension<AppShadows>()!;

  AppIconSizes get iconSizes => Theme.of(this).extension<AppIconSizes>()!;

  LayoutMetrics get layout => LayoutMetrics.of(this);
}
