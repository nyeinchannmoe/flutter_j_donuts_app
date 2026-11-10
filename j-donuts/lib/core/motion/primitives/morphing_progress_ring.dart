import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/painters/arc_sweep_painter.dart';
import 'package:jdonuts/core/motion/painters/check_morph_painter.dart';

/// Animates a circular progress value and optionally morphs into a check.
class MorphingProgressRing extends StatefulWidget {
  const MorphingProgressRing({
    required this.progress,
    required this.extent,
    required this.trackColor,
    required Color this.progressColor,
    required this.strokeWidth,
    this.completed = false,
    super.key,
  }) : gradientColors = null,
       _start = 0,
       checkColor = null;

  /// Starts at the previous step when the ring first appears.
  MorphingProgressRing.steps({
    required int step,
    required int totalSteps,
    required this.extent,
    required this.trackColor,
    required List<Color> this.gradientColors,
    required this.checkColor,
    this.completed = false,
    super.key,
  }) : assert(totalSteps > 0, 'A step ring needs at least one step.'),
       progress = step.clamp(0, totalSteps) / totalSteps,
       _start = (step - 1).clamp(0, totalSteps) / totalSteps,
       progressColor = null,
       strokeWidth = null;

  final double progress;
  final double _start;
  final double extent;
  final double? strokeWidth;
  final Color trackColor;
  final List<Color>? gradientColors;
  final Color? progressColor;
  final Color? checkColor;
  final bool completed;

  static const double strokeFraction = 0.18;
  static const double checkStrokeFraction = 0.6;

  @override
  State<MorphingProgressRing> createState() => _MorphingProgressRingState();
}

class _MorphingProgressRingState extends State<MorphingProgressRing>
    with TickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    value: widget._start,
  );
  late final AnimationController _morph = AnimationController(vsync: this);
  late final CurvedAnimation _morphCurve = CurvedAnimation(
    parent: _morph,
    curve: MotionTokens.emphasizedCurve,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_animateToTarget());
  }

  @override
  void didUpdateWidget(MorphingProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress ||
        oldWidget.completed != widget.completed) {
      unawaited(_animateToTarget());
    }
  }

  Future<void> _animateToTarget() async {
    final target = widget.progress.clamp(0.0, 1.0);
    if (MediaQuery.disableAnimationsOf(context)) {
      _progress.value = target;
      _morph.value = widget.completed ? 1 : 0;
      return;
    }
    final duration = context.motion.scaleDuration(MotionTokens.emphasized);
    _progress.duration = duration;
    _morph.duration = duration;
    try {
      if (!mounted) return;
      await _progress
          .animateTo(target, curve: MotionTokens.emphasizedCurve)
          .orCancel;
      if (!mounted) return;
      if (widget.completed) {
        await _morph.forward().orCancel;
      } else {
        await _morph.reverse().orCancel;
      }
    } on TickerCanceled {
      // A newer target or disposal superseded this transition.
    }
  }

  @override
  void dispose() {
    _morphCurve.dispose();
    _progress.dispose();
    _morph.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stroke =
        widget.strokeWidth ??
        widget.extent * MorphingProgressRing.strokeFraction;
    final gradient =
        widget.gradientColors ?? [widget.progressColor!, widget.progressColor!];
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.extent,
        child: CustomPaint(
          painter: ArcSweepPainter(
            progress: _progress,
            trackColor: widget.trackColor,
            gradientColors: gradient,
            strokeWidth: stroke,
          ),
          foregroundPainter: CheckMorphPainter(
            progress: _morphCurve,
            fillColor: gradient.last,
            checkColor: widget.checkColor ?? widget.trackColor,
            strokeWidth: stroke * MorphingProgressRing.checkStrokeFraction,
          ),
        ),
      ),
    );
  }
}
