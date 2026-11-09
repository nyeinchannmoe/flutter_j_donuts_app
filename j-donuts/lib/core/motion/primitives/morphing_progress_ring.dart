import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/painters/arc_sweep_painter.dart';
import 'package:jdonuts/core/motion/painters/check_morph_painter.dart';

/// Step ring for multi-step flows: animates from the previous step to
/// [step] of [totalSteps] (25, 50, 75, 100 percent for four steps), then
/// morphs into a check when [completed].
class MorphingProgressRing extends StatefulWidget {
  const MorphingProgressRing({
    required this.step,
    required this.totalSteps,
    required this.extent,
    required this.trackColor,
    required this.gradientColors,
    required this.checkColor,
    this.completed = false,
    super.key,
  });

  final int step;
  final int totalSteps;
  final double extent;
  final Color trackColor;
  final List<Color> gradientColors;
  final Color checkColor;
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
    value: _fractionBefore(widget.step),
  );
  late final AnimationController _morph = AnimationController(vsync: this);
  late final CurvedAnimation _morphCurve = CurvedAnimation(
    parent: _morph,
    curve: MotionTokens.emphasizedCurve,
  );

  double _fractionBefore(int step) =>
      (step - 1).clamp(0, widget.totalSteps) / widget.totalSteps;

  double get _target =>
      widget.step.clamp(0, widget.totalSteps) / widget.totalSteps;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_animateToTarget());
  }

  @override
  void didUpdateWidget(MorphingProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step ||
        oldWidget.completed != widget.completed) {
      unawaited(_animateToTarget());
    }
  }

  Future<void> _animateToTarget() async {
    final profile = context.motion;
    _progress.duration = profile.scaleDuration(MotionTokens.emphasized);
    _morph.duration = profile.scaleDuration(MotionTokens.emphasized);
    await _progress.animateTo(_target, curve: MotionTokens.emphasizedCurve);
    if (!mounted) return;
    if (widget.completed) {
      await _morph.forward();
    } else {
      await _morph.reverse();
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
    final stroke = widget.extent * MorphingProgressRing.strokeFraction;
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.extent,
        child: CustomPaint(
          painter: ArcSweepPainter(
            progress: _progress,
            trackColor: widget.trackColor,
            gradientColors: widget.gradientColors,
            strokeWidth: stroke,
          ),
          foregroundPainter: CheckMorphPainter(
            progress: _morphCurve,
            fillColor: widget.gradientColors.last,
            checkColor: widget.checkColor,
            strokeWidth: stroke * MorphingProgressRing.checkStrokeFraction,
          ),
        ),
      ),
    );
  }
}
