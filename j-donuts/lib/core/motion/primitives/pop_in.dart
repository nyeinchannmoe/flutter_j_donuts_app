import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Scales the child in with an overshoot once, after an optional delay
/// expressed as a fraction of the pop timeline.
class PopIn extends StatefulWidget {
  const PopIn({required this.child, this.delayFraction = 0, super.key});

  final Widget child;

  /// Portion (0 to 1) of the timeline to wait before popping.
  final double delayFraction;

  @override
  State<PopIn> createState() => _PopInState();
}

class _PopInState extends State<PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
  );
  late final CurvedAnimation _scaleCurve = CurvedAnimation(
    parent: _controller,
    curve: Interval(widget.delayFraction, 1, curve: MotionTokens.popOvershoot),
  );
  late final CurvedAnimation _fadeCurve = CurvedAnimation(
    parent: _controller,
    curve: Interval(widget.delayFraction, 1, curve: MotionTokens.decelerate),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: MotionTokens.popStartScale,
    end: 1,
  ).animate(_scaleCurve);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final profile = context.motion;
    _controller.duration = profile.scaleDuration(MotionTokens.emphasized);
    if (profile.animatesEntrances) {
      unawaited(_controller.forward());
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _scaleCurve.dispose();
    _fadeCurve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fadeCurve,
    child: ScaleTransition(scale: _scale, child: widget.child),
  );
}
