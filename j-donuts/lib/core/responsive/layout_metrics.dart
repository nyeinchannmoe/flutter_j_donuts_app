import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/responsive/screen_class.dart';

/// Derived layout values for the current screen.
@immutable
class LayoutMetrics {
  const LayoutMetrics._({
    required this.size,
    required this.screenClass,
    required this.isShortHeight,
    required this.scale,
  });

  factory LayoutMetrics.fromSize(Size size) {
    final rawScale = size.width / LayoutBreakpoints.designWidth;
    return LayoutMetrics._(
      size: size,
      screenClass: ScreenClass.fromWidth(size.width),
      isShortHeight: size.height < LayoutBreakpoints.shortHeightMax,
      scale: rawScale.clamp(minScale, maxScale),
    );
  }

  factory LayoutMetrics.of(BuildContext context) =>
      LayoutMetrics.fromSize(MediaQuery.sizeOf(context));

  static const double minScale = 0.85;
  static const double maxScale = 1.15;
  static const double _compactGutter = 16;
  static const double _regularGutter = 20;
  static const double _expandedGutter = 24;
  static const double maxContentWidth = 560;
  static const double _heroWidthFraction = 0.62;
  static const double _shortHeroWidthFraction = 0.5;
  static const double _minMotionScale = 0.8;
  static const double _maxMotionScale = 1.2;

  final Size size;
  final ScreenClass screenClass;
  final bool isShortHeight;

  /// Clamped width ratio against the design width.
  final double scale;

  double get horizontalGutter => switch (screenClass) {
    ScreenClass.compact => _compactGutter,
    ScreenClass.regular => _regularGutter,
    ScreenClass.expanded => _expandedGutter,
  };

  /// Square extent for the main product image.
  double get heroImageExtent =>
      size.width *
      (isShortHeight ? _shortHeroWidthFraction : _heroWidthFraction);

  /// Multiplier for animation travel distances and amplitudes.
  double get motionScale => scale.clamp(_minMotionScale, _maxMotionScale);

  /// Scales a spacing token for this screen.
  double space(double token) => token * scale;
}
