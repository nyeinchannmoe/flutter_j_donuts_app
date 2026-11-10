import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonuts/core/theme/tokens/app_colors.dart';

/// Vector stand-in for the welcome tile hero when the PNG is unavailable.
class WelcomeHeroPainter extends CustomPainter {
  const WelcomeHeroPainter({required this.colors});

  final AppColors colors;

  static const _tileRadius = 0.12;
  static const _gutter = 0.035;
  static const _leftShift = -0.04;
  static const _rightShift = 0.04;
  static const _leftTop = Rect.fromLTRB(-0.06, -0.04, 0.48, 0.42);
  static const _leftBottom = Rect.fromLTRB(-0.06, 0.38, 0.48, 0.78);
  static const _rightTop = Rect.fromLTRB(0.52, 0.06, 1.06, 0.5);
  static const _rightBottom = Rect.fromLTRB(0.52, 0.46, 1.06, 0.88);
  static const _doughFraction = 0.58;
  static const _holeFraction = 0.34;
  static const _glazeFraction = 0.94;
  static const _highlightOffset = Alignment(-0.35, -0.4);
  static const _stickCount = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final tiles = [
      (_leftTop, _tint(colors.primary, 0.42), colors.promoViolet),
      (_leftBottom, _tint(colors.highlight, 0.7), colors.accent),
      (_rightTop, _tint(colors.accent, 0.78), colors.accent),
      (_rightBottom, _tint(colors.highlight, 0.35), colors.textSecondary),
    ];
    for (final (bounds, fill, glaze) in tiles) {
      final rect = _map(bounds, size);
      final radius = Radius.circular(rect.width * _tileRadius);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        Paint()..color = fill,
      );
      _drawDonut(canvas, rect.center, rect.width * _doughFraction * 0.5, glaze);
      _drawSticks(canvas, rect, glaze);
    }
  }

  Rect _map(Rect normalized, Size size) => Rect.fromLTRB(
    (normalized.left + _leftShift) * size.width,
    normalized.top * size.height,
    (normalized.right + _rightShift) * size.width,
    normalized.bottom * size.height,
  );

  Color _tint(Color color, double amount) =>
      ColorTween(begin: color, end: colors.surface).lerp(amount)!;

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
            colors: [_tint(glaze, 0.55), glaze],
          ).createShader(Rect.fromCircle(center: center, radius: glazeRadius)),
      );
  }

  void _drawSticks(Canvas canvas, Rect tile, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = tile.width * _gutter * 0.55;
    final center = tile.center;
    for (var index = 0; index < _stickCount; index++) {
      final angle = index * math.pi * 2 / _stickCount;
      final start =
          center +
          Offset(math.cos(angle), math.sin(angle)) * tile.width * 0.28;
      final end =
          start +
          Offset(math.cos(angle + 0.8), math.sin(angle + 0.8)) *
              tile.width *
              0.08;
      canvas.drawLine(start, end, paint);
    }
  }

  Path _ring(Offset center, double radius, double hole) => Path()
    ..fillType = PathFillType.evenOdd
    ..addOval(Rect.fromCircle(center: center, radius: radius))
    ..addOval(Rect.fromCircle(center: center, radius: hole));

  @override
  bool shouldRepaint(WelcomeHeroPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
