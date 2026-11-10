import 'package:flutter/material.dart';

/// Samples a [LinearGradient] at [t] in `0..1` along its stops.
Color sampleLinearGradient(LinearGradient gradient, double t) {
  final clamped = t.clamp(0.0, 1.0);
  final colors = gradient.colors;
  if (colors.length == 1) return colors.first;
  final stops =
      gradient.stops ??
      [
        for (var index = 0; index < colors.length; index++)
          index / (colors.length - 1),
      ];
  if (clamped <= stops.first) return colors.first;
  if (clamped >= stops.last) return colors.last;
  for (var index = 0; index < stops.length - 1; index++) {
    final start = stops[index];
    final end = stops[index + 1];
    if (clamped > end) continue;
    final local = (clamped - start) / (end - start);
    return Color.lerp(colors[index], colors[index + 1], local)!;
  }
  return colors.last;
}
