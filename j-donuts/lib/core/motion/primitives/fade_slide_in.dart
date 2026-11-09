import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/responsive/layout_metrics.dart';

/// One-shot fade plus slide from [direction] times a travel distance.
/// The minimal tier keeps only a short fade.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    required this.child,
    this.direction = AxisDirection.up,
    this.distance = MotionTokens.travelMedium,
    this.duration = MotionTokens.entrance,
    super.key,
  });

  final Widget child;
  final AxisDirection direction;
  final double distance;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: MotionTokens.decelerate,
  );
  bool _started = false;
  Offset _origin = Offset.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final profile = context.motion;
    _controller.duration = profile.scaleDuration(widget.duration);
    if (profile.animatesEntrances) {
      _origin = _originFor(LayoutMetrics.of(context).motionScale);
    }
    unawaited(_controller.forward());
  }

  Offset _originFor(double motionScale) {
    final travel = widget.distance * motionScale;
    return switch (widget.direction) {
      AxisDirection.up => Offset(0, travel),
      AxisDirection.down => Offset(0, -travel),
      AxisDirection.left => Offset(travel, 0),
      AxisDirection.right => Offset(-travel, 0),
    };
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Transform.translate(
        offset: _origin * (1 - _curve.value),
        child: child,
      ),
      child: widget.child,
    ),
  );
}
