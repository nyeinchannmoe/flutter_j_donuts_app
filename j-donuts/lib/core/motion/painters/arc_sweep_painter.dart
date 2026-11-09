import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

/// Paints a background track and a round-capped arc sweeping clockwise
/// from 12 o'clock to [progress] (0 to 1).
///
/// Paint objects are created once; the sweep shader is rebuilt only when
/// the canvas size changes.
class ArcSweepPainter extends CustomPainter {
  ArcSweepPainter({
    required this.progress,
    required this.trackColor,
    required this.gradientColors,
    required this.strokeWidth,
  }) : _trackPaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeWidth = strokeWidth
         ..color = trackColor,
       _arcPaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeWidth = strokeWidth
         ..strokeCap = StrokeCap.round,
       super(repaint: progress);

  static const double _startAngle = -pi / 2;
  static const double _fullTurn = 2 * pi;

  final Animation<double> progress;
  final Color trackColor;
  final List<Color> gradientColors;
  final double strokeWidth;
  final Paint _trackPaint;
  final Paint _arcPaint;
  Size? _shaderSize;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    if (_shaderSize != size) {
      _shaderSize = size;
      _arcPaint.shader = SweepGradient(
        startAngle: _startAngle,
        endAngle: _startAngle + _fullTurn,
        colors: gradientColors,
        transform: const GradientRotation(_startAngle),
      ).createShader(rect);
    }
    canvas.drawArc(rect, 0, _fullTurn, false, _trackPaint);
    final sweep = progress.value.clamp(0.0, 1.0) * _fullTurn;
    if (sweep > 0) canvas.drawArc(rect, _startAngle, sweep, false, _arcPaint);
  }

  @override
  bool shouldRepaint(ArcSweepPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      !_sameColors(oldDelegate.gradientColors, gradientColors);

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
