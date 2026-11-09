import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';

/// Profile-aware page transition builders shared by routes and tabs.
///
/// Every builder collapses to a plain fade on the minimal tier.
abstract final class MotionTransitions {
  static Widget sharedAxisHorizontal({
    required MotionProfile profile,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    if (!profile.animatesEntrances) return _fade(animation, child);
    return SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      transitionType: SharedAxisTransitionType.horizontal,
      fillColor: Colors.transparent,
      child: child,
    );
  }

  static Widget fadeThrough({
    required MotionProfile profile,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    if (!profile.animatesEntrances) return _fade(animation, child);
    return FadeThroughTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      fillColor: Colors.transparent,
      child: child,
    );
  }

  /// Fade plus scale that leaves Hero flights untouched.
  static Widget fadeScale({
    required MotionProfile profile,
    required Animation<double> animation,
    required Widget child,
  }) {
    if (!profile.animatesEntrances) return _fade(animation, child);
    return FadeScaleTransition(animation: animation, child: child);
  }

  static Widget _fade(Animation<double> animation, Widget child) =>
      FadeTransition(opacity: animation, child: child);
}
