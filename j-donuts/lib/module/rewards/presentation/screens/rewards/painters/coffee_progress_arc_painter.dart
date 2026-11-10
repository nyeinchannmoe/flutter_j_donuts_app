import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

/// Top arch (upper semicircle) whose fill follows [progress] from 0 to 1.
class CoffeeProgressArcPainter extends CustomPainter {
  CoffeeProgressArcPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  }) : _trackPaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeWidth = strokeWidth
         ..strokeCap = StrokeCap.round
         ..color = trackColor,
       _fillPaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeWidth = strokeWidth
         ..strokeCap = StrokeCap.round
         ..color = fillColor,
       super(repaint: progress);

  /// Upper semicircle; positive sweep is clockwise over the top.
  static const double arcSpan = math.pi;

  /// Left tip of the crown (9 o'clock).
  static const double startAngle = math.pi;

  final Animation<double> progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;
  final Paint _trackPaint;
  final Paint _fillPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final side = math.min(size.width, size.height) - strokeWidth;
    if (side <= 0) return;
    final left = (size.width - side) / 2;
    final top = inset;
    final rect = Rect.fromLTWH(left, top, side, side);
    canvas.drawArc(rect, startAngle, arcSpan, false, _trackPaint);
    final t = progress.value.clamp(0.0, 1.0);
    if (t > 0) {
      canvas.drawArc(rect, startAngle, arcSpan * t, false, _fillPaint);
    }
  }

  @override
  bool shouldRepaint(CoffeeProgressArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
