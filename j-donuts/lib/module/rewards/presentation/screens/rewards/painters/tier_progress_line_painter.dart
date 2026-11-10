import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

/// Vertical track with an animated fill from top to [progress].
class TierProgressLinePainter extends CustomPainter {
  TierProgressLinePainter({
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

  final Animation<double> progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;
  final Paint _trackPaint;
  final Paint _fillPaint;

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final top = Offset(x, strokeWidth / 2);
    final bottom = Offset(x, size.height - strokeWidth / 2);
    canvas.drawLine(top, bottom, _trackPaint);
    final fill = progress.value.clamp(0.0, 1.0);
    if (fill <= 0) return;
    canvas.drawLine(
      top,
      Offset(x, top.dy + (bottom.dy - top.dy) * fill),
      _fillPaint,
    );
  }

  @override
  bool shouldRepaint(TierProgressLinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
