import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/transitions/motion_transitions.dart';

/// Page builders for every route. Durations come from MotionTokens and are
/// scaled by the active MotionProfile.
abstract final class RouteTransitions {
  /// Auth steps.
  static Page<void> sharedAxis(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => _page(context, state, child, MotionTransitions.sharedAxisHorizontal);

  /// Top-level destinations such as onboarding, welcome and the shell.
  static Page<void> fadeThrough(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => _page(context, state, child, MotionTransitions.fadeThrough);

  /// Product detail; keeps Hero flights intact.
  static Page<void> fadeScale(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) => _page(
    context,
    state,
    child,
    ({
      required profile,
      required animation,
      required secondaryAnimation,
      required child,
    }) => MotionTransitions.fadeScale(
      profile: profile,
      animation: animation,
      child: child,
    ),
  );

  static Page<void> _page(
    BuildContext context,
    GoRouterState state,
    Widget child,
    Widget Function({
      required MotionProfile profile,
      required Animation<double> animation,
      required Animation<double> secondaryAnimation,
      required Widget child,
    })
    transition,
  ) {
    final duration = context.motion.scaleDuration(MotionTokens.emphasized);
    return CustomTransitionPage<void>(
      key: state.pageKey,
      name: state.name,
      arguments: state.extra,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          transition(
            profile: context.motion,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
    );
  }
}
