import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Paints independently moving regions of one decoded texture. The final
/// frame draws the original image in one pass.
class OnboardingDiscEntrancePainter extends CustomPainter {
  OnboardingDiscEntrancePainter({
    required this.image,
    required this.tint,
    required this.tracks,
  }) : super(repaint: Listenable.merge(tracks));

  final ui.Image image;
  final Color tint;
  final List<Animation<double>> tracks;

  // Disc bounds are measured in the source artwork's normalized space.
  static const _discs = [
    (0, Rect.fromLTRB(-0.38, -0.16, 0.217, 0.335), -1.0),
    (0, Rect.fromLTRB(0.775, -0.12, 1.325, 0.337), 1.0),
    (1, Rect.fromLTRB(-0.306, 0.35, 0.207, 0.757), -1.0),
    (1, Rect.fromLTRB(0.789, 0.35, 1.304, 0.757), 1.0),
    (2, Rect.fromLTRB(0.197, 0.597, 0.811, 1.09), 0.0),
    (2, Rect.fromLTRB(0.188, 0.091, 0.805, 0.587), -0.5),
  ];

  static const _fullBlendStart = 0.7;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final source = Size(image.width.toDouble(), image.height.toDouble());
    final fitted = applyBoxFit(BoxFit.cover, source, size);
    final sample = Alignment.topCenter.inscribe(
      fitted.source,
      Offset.zero & source,
    );
    final bounds = Alignment.topCenter.inscribe(
      fitted.destination,
      Offset.zero & size,
    );
    final destination = _fullDestination(source, sample, bounds);
    final blend =
        ((tracks.last.value - _fullBlendStart) / (1 - _fullBlendStart)).clamp(
          0.0,
          1.0,
        );
    canvas
      ..save()
      ..clipRect(Offset.zero & size);
    if (blend > 0) _drawImage(canvas, source, destination, blend);
    if (blend < 1) _paintDiscs(canvas, source, destination, blend);
    canvas.restore();
  }

  Rect _fullDestination(Size source, Rect sample, Rect bounds) {
    final scale = bounds.width / sample.width;
    return Rect.fromLTWH(
      bounds.left - sample.left * scale,
      bounds.top - sample.top * scale,
      source.width * scale,
      source.height * scale,
    );
  }

  void _paintDiscs(Canvas canvas, Size source, Rect destination, double blend) {
    for (final (track, mask, horizontalDirection) in _discs) {
      final progress = tracks[track].value;
      if (progress == 0) continue;
      final travel = (1 - progress) * MotionTokens.onboardingDiscTravel;
      canvas
        ..save()
        ..translate(horizontalDirection * travel, travel)
        ..clipPath(Path()..addOval(_position(mask, destination)));
      _drawImage(canvas, source, destination, progress * (1 - blend));
      canvas.restore();
    }
  }

  Rect _position(Rect mask, Rect destination) => Rect.fromLTRB(
    destination.left + mask.left * destination.width,
    destination.top + mask.top * destination.height,
    destination.left + mask.right * destination.width,
    destination.top + mask.bottom * destination.height,
  );

  void _drawImage(
    Canvas canvas,
    Size source,
    Rect destination,
    double opacity,
  ) => canvas.drawImageRect(
    image,
    Offset.zero & source,
    destination,
    Paint()
      ..filterQuality = FilterQuality.low
      ..color = tint.withValues(alpha: opacity),
  );

  @override
  bool shouldRepaint(OnboardingDiscEntrancePainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.tint != tint ||
      oldDelegate.tracks != tracks;
}
