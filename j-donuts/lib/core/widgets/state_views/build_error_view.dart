import 'package:flutter/material.dart';
import 'package:jdonuts/core/theme/tokens/app_colors.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';

/// Replaces a widget that threw during build in profile and release.
///
/// It may be built above the theme or localizations, so every lookup is
/// optional.
class BuildErrorView extends StatelessWidget {
  const BuildErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return ColoredBox(
      color: colors.surfaceMuted,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: colors.textSecondary,
          semanticLabel: l10n?.screenErrorMessage,
        ),
      ),
    );
  }
}
