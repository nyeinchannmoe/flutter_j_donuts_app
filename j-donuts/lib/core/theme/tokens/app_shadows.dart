import 'package:flutter/material.dart';
import 'package:jdonuts/core/theme/app_palette.dart';

/// Static elevation tokens. Shadows are never animated.
@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({required this.card, required this.floating});

  static const AppShadows standard = AppShadows(
    card: [
      BoxShadow(color: AppPalette.shadow, blurRadius: 12, offset: Offset(0, 4)),
    ],
    floating: [
      BoxShadow(color: AppPalette.shadow, blurRadius: 24, offset: Offset(0, 8)),
    ],
  );

  final List<BoxShadow> card;
  final List<BoxShadow> floating;

  @override
  AppShadows copyWith({List<BoxShadow>? card}) =>
      AppShadows(card: card ?? this.card, floating: floating);

  @override
  AppShadows lerp(AppShadows? other, double t) =>
      t < 0.5 || other == null ? this : other;
}
