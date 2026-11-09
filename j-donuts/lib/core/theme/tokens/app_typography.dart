import 'package:flutter/material.dart';

/// Text style tokens. Sizes are logical pixels before the system text scale.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.display,
    required this.headline,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.bodyStrong,
    required this.caption,
    required this.label,
    required this.button,
    required this.metric,
  });

  factory AppTypography.withColor(Color color) => AppTypography(
    display: _style(_Sizes.display, FontWeight.w700, color, _Heights.tight),
    headline: _style(_Sizes.headline, FontWeight.w700, color, _Heights.tight),
    title: _style(_Sizes.title, FontWeight.w600, color, _Heights.normal),
    subtitle: _style(_Sizes.subtitle, FontWeight.w600, color, _Heights.normal),
    body: _style(_Sizes.body, FontWeight.w400, color, _Heights.relaxed),
    bodyStrong: _style(_Sizes.body, FontWeight.w600, color, _Heights.relaxed),
    caption: _style(_Sizes.caption, FontWeight.w400, color, _Heights.normal),
    label: _style(_Sizes.label, FontWeight.w500, color, _Heights.normal),
    button: _style(
      _Sizes.button,
      FontWeight.w700,
      color,
      _Heights.normal,
    ).copyWith(letterSpacing: _buttonLetterSpacing),
    metric: _style(_Sizes.metric, FontWeight.w700, color, _Heights.tight),
  );

  /// The single font family token; swapping fonts is a one-line change.
  static const String fontFamily = 'Outfit';
  static const double _buttonLetterSpacing = 1.2;

  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle subtitle;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle caption;
  final TextStyle label;
  final TextStyle button;
  final TextStyle metric;

  static TextStyle _style(
    double size,
    FontWeight weight,
    Color color,
    double height,
  ) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  @override
  AppTypography copyWith({TextStyle? body}) => AppTypography(
    display: display,
    headline: headline,
    title: title,
    subtitle: subtitle,
    body: body ?? this.body,
    bodyStrong: bodyStrong,
    caption: caption,
    label: label,
    button: button,
    metric: metric,
  );

  @override
  AppTypography lerp(AppTypography? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

abstract final class _Sizes {
  static const double display = 32;
  static const double headline = 26;
  static const double title = 20;
  static const double subtitle = 16;
  static const double body = 14;
  static const double caption = 12;
  static const double label = 13;
  static const double button = 14;
  static const double metric = 28;
}

abstract final class _Heights {
  static const double tight = 1.15;
  static const double normal = 1.3;
  static const double relaxed = 1.45;
}
