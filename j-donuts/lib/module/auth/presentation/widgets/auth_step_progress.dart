import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/morphing_progress_ring.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_count.dart';

/// Shared registration progress ring for phone, OTP, name and date of birth.
class AuthStepProgress extends StatelessWidget {
  const AuthStepProgress({
    required this.step,
    this.completed = false,
    super.key,
  });

  /// One-based step index within [authStepCount].
  final int step;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final extent = context.iconSizes.lg - context.spacing.xxs;
    return MorphingProgressRing.steps(
      step: step,
      totalSteps: authStepCount,
      extent: extent,
      trackColor: colors.tierColors.last,
      gradientColors: [colors.accent, colors.accent],
      checkColor: colors.onPrimary,
      completed: completed,
    );
  }
}
