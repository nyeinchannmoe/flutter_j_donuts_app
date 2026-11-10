import 'package:flutter/material.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Uses the Material control's press state so ripple and keyboard activation
/// keep their normal behavior.
class OnboardingPressFeedback extends StatelessWidget {
  const OnboardingPressFeedback({
    required this.states,
    required this.child,
    super.key,
  });

  final WidgetStatesController states;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context) ||
        !context.motion.animatesEntrances) {
      return child;
    }
    return ValueListenableBuilder(
      valueListenable: states,
      child: child,
      builder: (context, states, child) {
        final pressed = states.contains(WidgetState.pressed);
        return AnimatedScale(
          scale: pressed ? MotionTokens.pressedScale : 1,
          duration: pressed ? MotionTokens.micro : MotionTokens.fast,
          curve: pressed ? MotionTokens.decelerate : MotionTokens.popOvershoot,
          child: child,
        );
      },
    );
  }
}
