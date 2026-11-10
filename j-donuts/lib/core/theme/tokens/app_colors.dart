import 'package:flutter/material.dart';
import 'package:jdonuts/core/theme/app_palette.dart';

/// Semantic color tokens.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.accent,
    required this.highlight,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.border,
    required this.scrim,
    required this.success,
    required this.danger,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.authGradient,
    required this.tierColors,
    required this.offlineBanner,
    required this.onOfflineBanner,
    required this.headerWash,
    required this.headerDecor,
    required this.avatarGlow,
    required this.promoViolet,
    required this.promoSky,
  });

  static const AppColors light = AppColors(
    primary: AppPalette.skyBlue,
    onPrimary: AppPalette.white,
    accent: AppPalette.brandPink,
    highlight: AppPalette.orange,
    background: AppPalette.coolGray,
    surface: AppPalette.white,
    surfaceMuted: AppPalette.mist,
    textPrimary: AppPalette.ink,
    textSecondary: AppPalette.inkSoft,
    textDisabled: AppPalette.slate,
    border: AppPalette.stone,
    scrim: AppPalette.scrim,
    success: AppPalette.olive,
    danger: AppPalette.danger,
    shimmerBase: AppPalette.shimmerBase,
    shimmerHighlight: AppPalette.shimmerHighlight,
    authGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppPalette.blushTop,
        AppPalette.blushMid,
        AppPalette.blushBottom,
      ],
    ),
    tierColors: [
      AppPalette.orange,
      AppPalette.silver,
      AppPalette.gold,
      AppPalette.platinum,
    ],
    offlineBanner: AppPalette.ink,
    onOfflineBanner: AppPalette.white,
    headerWash: AppPalette.cream,
    headerDecor: AppPalette.peach,
    avatarGlow: AppPalette.peachDeep,
    promoViolet: AppPalette.violet,
    promoSky: AppPalette.skyBlue,
  );

  final Color primary;
  final Color onPrimary;
  final Color accent;
  final Color highlight;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color border;

  /// Overlay color that dims content behind a modal surface.
  final Color scrim;
  final Color success;
  final Color danger;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final LinearGradient authGradient;

  /// Tier medal colors indexed by tier sort order.
  final List<Color> tierColors;
  final Color offlineBanner;
  final Color onOfflineBanner;

  /// Cream plane behind the Home member header.
  final Color headerWash;

  /// Soft peach organic shapes in the Home header.
  final Color headerDecor;

  /// Warm halo behind the member avatar.
  final Color avatarGlow;

  /// Purple promo banner shell.
  final Color promoViolet;

  /// Cyan promo banner shell.
  final Color promoSky;

  Color tierColor(int sortOrder) =>
      tierColors[sortOrder.clamp(0, tierColors.length - 1)];

  /// Resolves a seed `cardTone` key to a banner shell color.
  Color bannerShell(String? tone) => switch (tone) {
    'sky' => promoSky,
    'violet' => promoViolet,
    _ => promoViolet,
  };

  @override
  AppColors copyWith({Color? primary, Color? accent, Color? scrim}) =>
      AppColors(
        primary: primary ?? this.primary,
        onPrimary: onPrimary,
        accent: accent ?? this.accent,
        highlight: highlight,
        background: background,
        surface: surface,
        surfaceMuted: surfaceMuted,
        textPrimary: textPrimary,
        textSecondary: textSecondary,
        textDisabled: textDisabled,
        border: border,
        scrim: scrim ?? this.scrim,
        success: success,
        danger: danger,
        shimmerBase: shimmerBase,
        shimmerHighlight: shimmerHighlight,
        authGradient: authGradient,
        tierColors: tierColors,
        offlineBanner: offlineBanner,
        onOfflineBanner: onOfflineBanner,
        headerWash: headerWash,
        headerDecor: headerDecor,
        avatarGlow: avatarGlow,
        promoViolet: promoViolet,
        promoSky: promoSky,
      );

  @override
  AppColors lerp(AppColors? other, double t) =>
      t < 0.5 || other == null ? this : other;
}
