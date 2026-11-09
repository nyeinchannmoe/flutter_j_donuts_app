import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/theme/tokens/app_colors.dart';

/// How wide the organic peach blob is relative to the avatar.
const double _blobWidthFactor = 3.4;

/// How tall the organic peach blob is relative to the avatar.
const double _blobHeightFactor = 2.6;

/// How far the star badge sits past the trailing edge, relative to spacing.
const double _starTrailFactor = 0.45;

/// Side count for the decorative membership hexagon.
const int _hexagonSides = 6;

/// Soft peach shapes and membership star drawn behind the member header.
class MemberHeaderDecor extends StatelessWidget {
  const MemberHeaderDecor({required this.avatarExtent, super.key});

  final double avatarExtent;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            start: -spacing.xl,
            top: -spacing.md,
            child: _OrganicBlob(
              width: avatarExtent * _blobWidthFactor,
              height: avatarExtent * _blobHeightFactor,
              color: context.colors.headerDecor,
            ),
          ),
          PositionedDirectional(
            end: -spacing.xxxl * _starTrailFactor,
            top: -spacing.sm,
            child: _MembershipBadge(
              extent: avatarExtent + spacing.xxl,
              colors: context.colors,
            ),
          ),
        ],
      ),
    );
  }
}

/// Opacity for the warm ribbon behind the badge.
const double _ribbonOpacity = 0.55;

/// Opacity for the faint hexagon fill.
const double _hexFillOpacity = 0.55;

/// Opacity for the hexagon outline.
const double _hexStrokeOpacity = 0.85;

class _OrganicBlob extends StatelessWidget {
  const _OrganicBlob({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(-0.2, -0.1),
        radius: _blobGradientRadius,
        colors: [color, color.withValues(alpha: _blobEdgeOpacity)],
      ),
      borderRadius: context.radius.xlAll,
    ),
    child: SizedBox(width: width, height: height),
  );
}

/// Soft edge opacity for the organic wash blob.
const double _blobEdgeOpacity = 0.25;

/// Radial gradient extent for the organic wash blob.
const double _blobGradientRadius = 0.9;

class _MembershipBadge extends StatelessWidget {
  const _MembershipBadge({required this.extent, required this.colors});

  final double extent;
  final AppColors colors;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: extent,
    child: CustomPaint(
      painter: _MembershipBadgePainter(
        ribbon: colors.highlight.withValues(alpha: _ribbonOpacity),
        hexFill: colors.onPrimary.withValues(alpha: _hexFillOpacity),
        hexStroke: colors.onPrimary.withValues(alpha: _hexStrokeOpacity),
        star: colors.textDisabled,
      ),
    ),
  );
}

class _MembershipBadgePainter extends CustomPainter {
  _MembershipBadgePainter({
    required this.ribbon,
    required this.hexFill,
    required this.hexStroke,
    required this.star,
  });

  final Color ribbon;
  final Color hexFill;
  final Color hexStroke;
  final Color star;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    _paintRibbon(canvas, center, radius);
    final hexPath = _hexagon(center, radius * _hexRadiusFactor);
    canvas
      ..drawPath(hexPath, Paint()..color = hexFill)
      ..drawPath(
        hexPath,
        Paint()
          ..color = hexStroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.shortestSide * _hexStrokeFactor,
      );
    final starPaint = Paint()
      ..color = star
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * _starStrokeFactor
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_star(center, radius * _starRadiusFactor), starPaint);
  }

  void _paintRibbon(Canvas canvas, Offset center, double radius) {
    final ribbonCenter = center.translate(
      radius * _ribbonOffsetX,
      radius * _ribbonOffsetY,
    );
    final rect = Rect.fromCenter(
      center: ribbonCenter,
      width: radius * _ribbonWidthFactor,
      height: radius * _ribbonHeightFactor,
    );
    canvas.drawOval(rect, Paint()..color = ribbon);
  }

  Path _hexagon(Offset center, double radius) {
    final path = Path();
    for (var i = 0; i < _hexagonSides; i++) {
      final angle =
          (math.pi / _hexagonSides) + (i * 2 * math.pi / _hexagonSides);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  Path _star(Offset center, double radius) {
    const points = _starPoints;
    final path = Path();
    for (var i = 0; i < points; i++) {
      final outerAngle = -math.pi / 2 + i * 2 * math.pi / points;
      final innerAngle = outerAngle + math.pi / points;
      final outer = Offset(
        center.dx + radius * math.cos(outerAngle),
        center.dy + radius * math.sin(outerAngle),
      );
      final inner = Offset(
        center.dx + radius * _starInnerFactor * math.cos(innerAngle),
        center.dy + radius * _starInnerFactor * math.sin(innerAngle),
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _MembershipBadgePainter oldDelegate) =>
      oldDelegate.ribbon != ribbon ||
      oldDelegate.hexFill != hexFill ||
      oldDelegate.hexStroke != hexStroke ||
      oldDelegate.star != star;
}

/// Outer points on the membership star.
const int _starPoints = 5;

/// Inner radius of the star relative to the outer radius.
const double _starInnerFactor = 0.42;

/// Star radius relative to the badge radius.
const double _starRadiusFactor = 0.34;

/// Hexagon radius relative to the badge radius.
const double _hexRadiusFactor = 0.72;

/// Stroke width of the star relative to the badge extent.
const double _starStrokeFactor = 0.045;

/// Stroke width of the hexagon relative to the badge extent.
const double _hexStrokeFactor = 0.028;

/// Ribbon oval width relative to badge radius.
const double _ribbonWidthFactor = 1.55;

/// Ribbon oval height relative to badge radius.
const double _ribbonHeightFactor = 1.15;

/// Ribbon horizontal offset relative to badge radius.
const double _ribbonOffsetX = 0.12;

/// Ribbon vertical offset relative to badge radius.
const double _ribbonOffsetY = 0.08;
