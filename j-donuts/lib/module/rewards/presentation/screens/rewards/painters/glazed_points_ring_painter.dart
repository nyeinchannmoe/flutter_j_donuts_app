import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

/// Hot-pink glazed progress ring with thin deterministic sprinkles.
class GlazedPointsRingPainter extends CustomPainter {
  GlazedPointsRingPainter({
    required this.progress,
    required this.trackColor,
    required this.glazeDeep,
    required this.glazeMid,
    required this.sprinkleColor,
    required this.strokeWidth,
    this.sprinkleReveal = 1,
    this.leaderGlow = 0,
    this.bandShine = 0,
  }) : _trackPaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeWidth = strokeWidth
         ..strokeCap = StrokeCap.round
         ..color = trackColor,
       _glazePaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeWidth = strokeWidth
         ..strokeCap = StrokeCap.round,
       _sprinklePaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeCap = StrokeCap.round
         ..color = sprinkleColor,
       _glowPaint = Paint()
         ..style = PaintingStyle.fill
         ..color = glazeMid.withValues(alpha: 0.55),
       _shinePaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeCap = StrokeCap.round
         ..color = glazeMid.withValues(alpha: 0.45),
       super(repaint: progress);

  static const double _startAngle = -math.pi / 2;
  static const double _fullTurn = 2 * math.pi;
  static const int _sprinkleSeed = 17;
  static const int _sprinkleCount = 14;
  static const double _sprinkleWidthFactor = 0.05;
  static const double _sprinkleLengthFactor = 0.2;
  static const double _bandInsetFactor = 0.18;

  final Animation<double> progress;
  final Color trackColor;
  final Color glazeDeep;
  final Color glazeMid;
  final Color sprinkleColor;
  final double strokeWidth;
  final double sprinkleReveal;
  final double leaderGlow;
  final double bandShine;

  final Paint _trackPaint;
  final Paint _glazePaint;
  final Paint _sprinklePaint;
  final Paint _glowPaint;
  final Paint _shinePaint;

  List<_Sprinkle>? _sprinkles;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect = (Offset.zero & size).deflate(inset);
    final radius = rect.shortestSide / 2;
    final center = rect.center;
    _ensureSprinkles(radius);
    canvas.drawArc(rect, 0, _fullTurn, false, _trackPaint);
    final sweep = progress.value.clamp(0.0, 1.0) * _fullTurn;
    if (sweep <= 0) return;
    _bindTubeShader(center, radius);
    canvas.drawArc(rect, _startAngle, sweep, false, _glazePaint);
    _paintSprinkles(canvas, center, radius, sweep);
    _paintLeader(canvas, center, radius, sweep);
    _paintShine(canvas, rect, sweep);
  }

  void _bindTubeShader(Offset center, double radius) {
    final outer = radius + strokeWidth / 2;
    _glazePaint.shader = ui.Gradient.radial(
      center,
      outer,
      [glazeDeep, glazeMid, glazeDeep],
      const [0.0, 0.52, 1.0],
    );
  }

  void _ensureSprinkles(double radius) {
    if (_sprinkles != null) return;
    final random = math.Random(_sprinkleSeed);
    final length = radius * _sprinkleLengthFactor;
    final halfBand = strokeWidth * (0.5 - _bandInsetFactor);
    _sprinkles = [
      for (var i = 0; i < _sprinkleCount; i++)
        _Sprinkle(
          angle: (i + 0.35) / _sprinkleCount * _fullTurn * 0.74,
          radialJitter: (random.nextDouble() - 0.5) * halfBand * 2,
          rotation: random.nextDouble() * math.pi,
          length: length * (0.75 + random.nextDouble() * 0.4),
        ),
    ];
    _sprinklePaint.strokeWidth = radius * _sprinkleWidthFactor;
  }

  void _paintSprinkles(
    Canvas canvas,
    Offset center,
    double radius,
    double sweep,
  ) {
    final sprinkles = _sprinkles;
    if (sprinkles == null) return;
    for (final sprinkle in sprinkles) {
      if (sprinkle.angle > sweep) continue;
      final scale = sprinkleReveal.clamp(0.0, 1.0);
      if (scale <= 0) continue;
      final angle = _startAngle + sprinkle.angle;
      final point =
          center +
          Offset(math.cos(angle), math.sin(angle)) *
              (radius + sprinkle.radialJitter);
      final half = sprinkle.length * scale / 2;
      final dx = math.cos(sprinkle.rotation) * half;
      final dy = math.sin(sprinkle.rotation) * half;
      canvas.drawLine(
        point - Offset(dx, dy),
        point + Offset(dx, dy),
        _sprinklePaint,
      );
    }
  }

  void _paintLeader(Canvas canvas, Offset center, double radius, double sweep) {
    if (leaderGlow <= 0 || sweep <= 0) return;
    final angle = _startAngle + sweep;
    final point =
        center + Offset(math.cos(angle), math.sin(angle)) * radius;
    canvas.drawCircle(point, strokeWidth * 0.28 * leaderGlow, _glowPaint);
  }

  void _paintShine(Canvas canvas, Rect rect, double sweep) {
    if (bandShine <= 0 || sweep <= 0) return;
    _shinePaint.strokeWidth = strokeWidth * 0.35;
    final shineSweep = math.min(sweep, _fullTurn * 0.12);
    final start = _startAngle + sweep * bandShine - shineSweep;
    canvas.drawArc(rect, start, shineSweep, false, _shinePaint);
  }

  @override
  bool shouldRepaint(GlazedPointsRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.glazeDeep != glazeDeep ||
      oldDelegate.glazeMid != glazeMid ||
      oldDelegate.sprinkleColor != sprinkleColor ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.sprinkleReveal != sprinkleReveal ||
      oldDelegate.leaderGlow != leaderGlow ||
      oldDelegate.bandShine != bandShine;
}

class _Sprinkle {
  const _Sprinkle({
    required this.angle,
    required this.radialJitter,
    required this.rotation,
    required this.length,
  });

  final double angle;
  final double radialJitter;
  final double rotation;
  final double length;
}
