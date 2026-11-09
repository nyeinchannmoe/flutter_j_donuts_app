import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

/// Grows a filled disc and then strokes a check mark as [progress] goes
/// from 0 to 1. The disc fills the first half, the check the second.
class CheckMorphPainter extends CustomPainter {
  CheckMorphPainter({
    required this.progress,
    required this.fillColor,
    required this.checkColor,
    required this.strokeWidth,
  }) : _fillPaint = Paint()..color = fillColor,
       _checkPaint = Paint()
         ..color = checkColor
         ..style = PaintingStyle.stroke
         ..strokeCap = StrokeCap.round
         ..strokeWidth = strokeWidth,
       super(repaint: progress);

  static const double _discPhaseEnd = 0.5;
  static const double _shortStrokeShare = 0.4;
  static const Offset _checkStart = Offset(0.28, 0.52);
  static const Offset _checkCorner = Offset(0.44, 0.67);
  static const Offset _checkEnd = Offset(0.73, 0.36);

  final Animation<double> progress;
  final Color fillColor;
  final Color checkColor;
  final double strokeWidth;
  final Paint _fillPaint;
  final Paint _checkPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value.clamp(0.0, 1.0);
    if (t == 0) return;
    final center = size.center(Offset.zero);
    final discT = (t / _discPhaseEnd).clamp(0.0, 1.0);
    canvas.drawCircle(center, size.shortestSide / 2 * discT, _fillPaint);
    final checkT = ((t - _discPhaseEnd) / (1 - _discPhaseEnd)).clamp(0.0, 1.0);
    if (checkT > 0) _paintCheck(canvas, size, checkT);
  }

  void _paintCheck(Canvas canvas, Size size, double t) {
    final start = _scale(_checkStart, size);
    final corner = _scale(_checkCorner, size);
    final end = _scale(_checkEnd, size);
    final shortT = (t / _shortStrokeShare).clamp(0.0, 1.0);
    canvas.drawLine(start, Offset.lerp(start, corner, shortT)!, _checkPaint);
    if (t <= _shortStrokeShare) return;
    final longT = (t - _shortStrokeShare) / (1 - _shortStrokeShare);
    canvas.drawLine(corner, Offset.lerp(corner, end, longT)!, _checkPaint);
  }

  static Offset _scale(Offset unit, Size size) =>
      Offset(unit.dx * size.width, unit.dy * size.height);

  @override
  bool shouldRepaint(CheckMorphPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.checkColor != checkColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
