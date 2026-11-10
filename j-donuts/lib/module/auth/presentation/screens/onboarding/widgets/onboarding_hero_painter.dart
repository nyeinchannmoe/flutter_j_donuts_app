import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonuts/core/theme/tokens/app_colors.dart';

/// Bundled-image fallback with the same circular composition.
class OnboardingHeroPainter extends CustomPainter {
  const OnboardingHeroPainter({
    required this.colors,
    required this.glazeShadow,
  });

  final AppColors colors;
  final Color glazeShadow;

  List<(Offset, double, Color, Color)> get _discs {
    final cyan = colors.primary;
    final pink = colors.accent;

    final cocoa = colors.textSecondary;
    final lilac = _tint(pink, _pastelAmount);
    final blue = _tint(cyan, _pastelAmount);
    final yellow = _tint(colors.highlight, _pastelAmount);
    final peach = _tint(colors.highlight, _peachAmount);
    return [
      (const Offset(0, 0.07), 0.22, cyan, cocoa),
      (const Offset(0, 0.57), 0.22, lilac, glazeShadow),
      (const Offset(1, 0.08), 0.23, blue, pink),
      (const Offset(1, 0.57), 0.22, blue, glazeShadow),
      (const Offset(0.5, 0.88), 0.29, yellow, cocoa),
      (const Offset(0.5, 0.36), 0.31, peach, pink),
    ];
  }

  Color _tint(Color color, double amount) =>
      ColorTween(begin: color, end: colors.surface).lerp(amount)!;

  static const _pastelAmount = 0.48;
  static const _peachAmount = 0.72;
  static const _highlightAmount = 0.58;
  static const _doughFraction = 0.59;
  static const _holeFraction = 0.34;
  static const _glazeFraction = 0.94;
  static const _highlightOffset = Alignment(-0.35, -0.4);
  static const _sprinkleCount = 14;

  @override
  void paint(Canvas canvas, Size size) {
    for (final (position, radius, background, glaze) in _discs) {
      final center = Offset(
        position.dx * size.width,
        position.dy * size.height,
      );
      final discRadius = radius * size.width;
      canvas.drawCircle(center, discRadius, Paint()..color = background);
      _drawDonut(canvas, center, discRadius * _doughFraction, glaze);
    }
  }

  void _drawDonut(Canvas canvas, Offset center, double radius, Color glaze) {
    final hole = radius * _holeFraction;
    final glazeRadius = radius * _glazeFraction;
    canvas
      ..drawPath(
        _ring(center, radius, hole),
        Paint()..color = colors.highlight,
      )
      ..drawPath(
        _ring(center, glazeRadius, hole),
        Paint()
          ..shader = RadialGradient(
            center: _highlightOffset,
            colors: [_tint(glaze, _highlightAmount), glaze],
          ).createShader(Rect.fromCircle(center: center, radius: glazeRadius)),
      );
    _drawSprinkles(canvas, center, radius);
  }

  Path _ring(Offset center, double radius, double hole) => Path()
    ..fillType = PathFillType.evenOdd
    ..addOval(Rect.fromCircle(center: center, radius: radius))
    ..addOval(Rect.fromCircle(center: center, radius: hole));

  void _drawSprinkles(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = colors.textSecondary
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.038;
    for (var index = 0; index < _sprinkleCount; index++) {
      final angle = index * math.pi * 2 / _sprinkleCount;
      final offset = Offset(math.cos(angle), math.sin(angle)) * radius * 0.7;
      final tip =
          Offset(math.cos(angle + 1), math.sin(angle + 1)) * radius * 0.12;
      canvas.drawLine(center + offset, center + offset + tip, paint);
    }
  }

  @override
  bool shouldRepaint(OnboardingHeroPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
