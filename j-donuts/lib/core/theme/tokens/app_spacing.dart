import 'package:flutter/material.dart';

/// Spacing scale on a 4 dp grid.
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.xxs = 2,
    this.xs = 4,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
    this.xxxl = 48,
  });

  static const AppSpacing standard = AppSpacing();

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;

  @override
  AppSpacing copyWith({double? lg}) => AppSpacing(
    xxs: xxs,
    xs: xs,
    sm: sm,
    md: md,
    lg: lg ?? this.lg,
    xl: xl,
    xxl: xxl,
    xxxl: xxxl,
  );

  @override
  AppSpacing lerp(AppSpacing? other, double t) =>
      t < 0.5 || other == null ? this : other;
}
