import 'package:flutter/material.dart';

/// Corner radius tokens.
@immutable
class AppRadius extends ThemeExtension<AppRadius> {
  const AppRadius({
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 24,
    this.xxl = 32,
    this.pill = 999,
  });

  static const AppRadius standard = AppRadius();

  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double pill;

  BorderRadius get smAll => BorderRadius.circular(sm);
  BorderRadius get mdAll => BorderRadius.circular(md);
  BorderRadius get lgAll => BorderRadius.circular(lg);
  BorderRadius get xlAll => BorderRadius.circular(xl);
  BorderRadius get xxlAll => BorderRadius.circular(xxl);
  BorderRadius get pillAll => BorderRadius.circular(pill);

  @override
  AppRadius copyWith({double? md}) => AppRadius(
    sm: sm,
    md: md ?? this.md,
    lg: lg,
    xl: xl,
    xxl: xxl,
    pill: pill,
  );

  @override
  AppRadius lerp(AppRadius? other, double t) =>
      t < 0.5 || other == null ? this : other;
}
