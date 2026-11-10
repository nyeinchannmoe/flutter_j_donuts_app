import 'package:flutter/material.dart';

/// Soft transparent-to-[color] wash that hides the lower edge of a hero.
class HeroEdgeFade extends StatelessWidget {
  const HeroEdgeFade({
    required this.color,
    this.fadeStart = _defaultFadeStart,
    super.key,
  });

  /// Fraction of the hero height where the wash becomes opaque.
  static const double _defaultFadeStart = 0.75;

  final Color color;
  final double fadeStart;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0), color],
        stops: [fadeStart, 1],
      ),
    ),
  );
}
