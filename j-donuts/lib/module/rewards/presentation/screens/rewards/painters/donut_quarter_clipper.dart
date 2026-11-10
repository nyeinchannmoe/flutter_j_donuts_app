import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// Reveals [quarters] pie slices clockwise from the top-right quadrant.
class DonutQuarterClipper extends CustomClipper<Path> {
  const DonutQuarterClipper({required this.quarters});

  /// Number of colored quarters from 0 to 4.
  final int quarters;

  static const double _quarterSweep = math.pi / 2;
  static const double _topRightStart = -math.pi / 2;

  @override
  Path getClip(Size size) {
    if (quarters <= 0) return Path();
    if (quarters >= 4) {
      return Path()..addRect(Offset.zero & size);
    }
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final sweep = _quarterSweep * quarters;
    return Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        _topRightStart,
        sweep,
        false,
      )
      ..close();
  }

  @override
  bool shouldReclip(DonutQuarterClipper oldClipper) =>
      oldClipper.quarters != quarters;
}
