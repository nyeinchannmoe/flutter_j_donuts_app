import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/responsive/layout_metrics.dart';

/// Shakes [child] horizontally each time [trigger] changes, with a
/// decaying sine. The minimal tier skips the shake.
class ShakeOnTrigger extends StatefulWidget {
  const ShakeOnTrigger({
    required this.trigger,
    required this.child,
    super.key,
  });

  /// Incremented by the caller to request a shake.
  final int trigger;
  final Widget child;

  @override
  State<ShakeOnTrigger> createState() => _ShakeOnTriggerState();
}

class _ShakeOnTriggerState extends State<ShakeOnTrigger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
  );

  @override
  void didUpdateWidget(ShakeOnTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger == widget.trigger) return;
    final profile = context.motion;
    if (!profile.animatesEntrances) return;
    _controller.duration = profile.scaleDuration(MotionTokens.emphasized);
    unawaited(_controller.forward(from: 0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amplitude =
        MotionTokens.shakeAmplitude * LayoutMetrics.of(context).motionScale;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final dx =
            sin(t * MotionTokens.shakeCycles * 2 * pi) * amplitude * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}
