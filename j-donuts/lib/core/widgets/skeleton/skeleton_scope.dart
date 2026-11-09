import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Shimmer clock handed to SkeletonGroups. Groups acquire it while they
/// are mounted, so the controller ticks only while a skeleton is visible.
abstract interface class SkeletonShimmer {
  Animation<double> get animation;

  void acquire();

  void release();
}

/// Owns the one shimmer controller shared by every SkeletonGroup below it.
/// The shimmer is static on the minimal motion tier.
class SkeletonScope extends StatefulWidget {
  const SkeletonScope({required this.child, super.key});

  final Widget child;

  static SkeletonShimmer? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_SkeletonShimmerScope>()?.shimmer;

  @override
  State<SkeletonScope> createState() => _SkeletonScopeState();
}

class _SkeletonScopeState extends State<SkeletonScope>
    with SingleTickerProviderStateMixin
    implements SkeletonShimmer {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionTokens.shimmer,
  );
  int _users = 0;
  bool _animates = true;

  @override
  Animation<double> get animation => _controller;

  @override
  void acquire() {
    _users++;
    _sync();
  }

  @override
  void release() {
    _users--;
    _sync();
  }

  void _sync() {
    if (_users > 0 && _animates) {
      if (!_controller.isAnimating) unawaited(_controller.repeat());
    } else {
      _controller.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animates = context.motion.animatesEntrances;
    _sync();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _SkeletonShimmerScope(shimmer: this, child: widget.child);
}

class _SkeletonShimmerScope extends InheritedWidget {
  const _SkeletonShimmerScope({required this.shimmer, required super.child});

  final SkeletonShimmer shimmer;

  @override
  bool updateShouldNotify(_SkeletonShimmerScope oldWidget) =>
      oldWidget.shimmer != shimmer;
}
