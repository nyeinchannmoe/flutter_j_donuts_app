import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Staggers four clipped regions of one welcome hero texture.
///
/// Approach: one decoded image is painted per tile through a rounded clip
/// rectangle so each column can slide independently while the settled frame
/// matches the composite artwork.
class WelcomeTileEntrancePainter extends CustomPainter {
  WelcomeTileEntrancePainter({
    required this.image,
    required this.tint,
    required this.tracks,
    required this.travel,
  }) : super(repaint: Listenable.merge(tracks));

  final ui.Image image;
  final Color tint;
  final List<Animation<double>> tracks;
  final double travel;

  // Normalized tile bounds measured against the source artwork.
  static const _tiles = [
    (0, Rect.fromLTRB(-0.04, -0.02, 0.5, 0.44), -1.0, -0.35),
    (1, Rect.fromLTRB(-0.04, 0.38, 0.5, 0.8), -1.0, -0.2),
    (2, Rect.fromLTRB(0.5, 0.06, 1.04, 0.5), 1.0, 0.35),
    (3, Rect.fromLTRB(0.5, 0.46, 1.04, 0.9), 1.0, 0.45),
  ];

  static const _corner = 0.11;
  static const _fullBlendStart = 0.72;

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
    if (blend < 1) _paintTiles(canvas, source, destination, blend);
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

  void _paintTiles(
    Canvas canvas,
    Size source,
    Rect destination,
    double blend,
  ) {
    for (final (track, mask, horizontal, vertical) in _tiles) {
      final progress = tracks[track].value;
      if (progress == 0) continue;
      final curved = MotionTokens.popOvershoot.transform(progress);
      final remain = (1 - curved).clamp(0.0, 1.2);
      canvas
        ..save()
        ..translate(horizontal * travel * remain, vertical * travel * remain)
        ..clipRRect(
          RRect.fromRectAndRadius(
            _position(mask, destination),
            Radius.circular(destination.width * _corner),
          ),
        );
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
  bool shouldRepaint(WelcomeTileEntrancePainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.tint != tint ||
      oldDelegate.tracks != tracks ||
      oldDelegate.travel != travel;
}
