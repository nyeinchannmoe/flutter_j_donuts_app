import 'package:flutter/material.dart';

/// Icon and avatar size tokens.
@immutable
class AppIconSizes extends ThemeExtension<AppIconSizes> {
  const AppIconSizes({
    this.sm = 16,
    this.md = 24,
    this.lg = 32,
    this.xl = 48,
    this.avatar = 48,
    this.illustration = 96,
  });

  static const AppIconSizes standard = AppIconSizes();

  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double avatar;
  final double illustration;

  @override
  AppIconSizes copyWith({double? md}) => AppIconSizes(
    sm: sm,
    md: md ?? this.md,
    lg: lg,
    xl: xl,
    avatar: avatar,
    illustration: illustration,
  );

  @override
  AppIconSizes lerp(AppIconSizes? other, double t) =>
      t < 0.5 || other == null ? this : other;
}
