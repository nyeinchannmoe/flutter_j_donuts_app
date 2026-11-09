import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/fade_slide_in.dart';
import 'package:jdonuts/core/motion/primitives/morphing_progress_ring.dart';

/// Number of steps in the sign-up flow: phone, code, name, date of birth.
const int authStepCount = 4;

/// Shared frame for each auth step: back button, step ring, headline,
/// content and a bottom action that stays above the keyboard.
class AuthStepScaffold extends StatelessWidget {
  const AuthStepScaffold({
    required this.step,
    required this.title,
    required this.action,
    required this.child,
    this.completed = false,
    super.key,
  });

  /// One-based step index.
  final int step;
  final String title;
  final Widget action;
  final Widget child;
  final bool completed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(gradient: context.colors.authGradient),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: context.colors.textPrimary),
        actions: [_StepRing(step: step, completed: completed)],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.layout.horizontalGutter),
          child: _body(context),
        ),
      ),
    ),
  );

  Widget _body(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FadeSlideIn(
        child: Semantics(
          header: true,
          child: Text(title, style: context.typography.headline),
        ),
      ),
      SizedBox(height: context.spacing.xl),
      Expanded(child: SingleChildScrollView(child: child)),
      SizedBox(height: context.spacing.lg),
      action,
    ],
  );
}

class _StepRing extends StatelessWidget {
  const _StepRing({required this.step, required this.completed});

  final int step;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsetsDirectional.only(end: context.layout.horizontalGutter),
      child: MorphingProgressRing(
        step: step,
        totalSteps: authStepCount,
        extent: context.iconSizes.lg,
        trackColor: colors.surface,
        gradientColors: [colors.primary, colors.accent],
        checkColor: colors.onPrimary,
        completed: completed,
      ),
    );
  }
}
