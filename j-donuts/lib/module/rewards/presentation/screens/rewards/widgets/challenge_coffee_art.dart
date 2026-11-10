import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/presentation/screens/rewards/painters/coffee_progress_arc_painter.dart';

/// Cup width as a fraction of the art box (narrower than the arc).
const double _cupWidthFraction = 0.62;

/// Arc diameter as a fraction of the art box (wider than the cup).
const double _arcDiameterFraction = 0.92;

/// Top padding so the arc apex clears the card edge.
const double _arcTopPaddingFraction = 0.04;

/// How far below the rim the arc ends sit, as a fraction of cup height.
const double _endsBelowRimFraction = 0.22;

/// Coffee challenge art with a top arch painted behind the cup.
class ChallengeCoffeeArt extends StatefulWidget {
  const ChallengeCoffeeArt({required this.challenge, super.key});

  final Challenge challenge;

  @override
  State<ChallengeCoffeeArt> createState() => _ChallengeCoffeeArtState();
}

class _ChallengeCoffeeArtState extends State<ChallengeCoffeeArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.motion.scaleDuration(
      MotionTokens.artworkReveal,
    );
    if (_started || !TickerMode.valuesOf(context).enabled) return;
    _started = true;
    unawaited(
      _controller.animateTo(
        widget.challenge.progressFraction,
        curve: MotionTokens.decelerate,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final stroke = context.spacing.xs;
    return AspectRatio(
      aspectRatio: 3 / 5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final artWidth = constraints.maxWidth;
          final artHeight = constraints.maxHeight;
          final arcDiameter = artWidth * _arcDiameterFraction;
          final cupWidth = artWidth * _cupWidthFraction;
          final cupHeight = artHeight * 0.72;
          final topPad = artHeight * _arcTopPaddingFraction;
          final arcCenterY = topPad + arcDiameter / 2;
          final rimY = arcCenterY - cupHeight * _endsBelowRimFraction;
          final cupTop = rimY;
          final cupLeft = (artWidth - cupWidth) / 2;
          final arcLeft = (artWidth - arcDiameter) / 2;
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: arcLeft,
                top: topPad,
                width: arcDiameter,
                height: arcDiameter,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: CoffeeProgressArcPainter(
                      progress: _controller,
                      trackColor: colors.border,
                      fillColor: colors.highlight,
                      strokeWidth: stroke,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: cupLeft,
                top: cupTop,
                width: cupWidth,
                height: cupHeight,
                child: AppImage(
                  image: AssetImageRef(widget.challenge.imageAsset),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
