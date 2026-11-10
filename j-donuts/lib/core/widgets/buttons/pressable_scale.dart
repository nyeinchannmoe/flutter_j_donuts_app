import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Scales [child] down while pressed. Taps are reported through [onTap];
/// a null [onTap] disables both the gesture and the feedback.
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.onTap,
    this.pressedScale = MotionTokens.pressedScale,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
  );
  late final Animation<double> _scale =
      Tween<double>(
        begin: 1,
        end: widget.pressedScale,
      ).animate(
        CurvedAnimation(parent: _controller, curve: MotionTokens.decelerate),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.motion.scaleDuration(MotionTokens.micro);
  }

  void _press() {
    if (MediaQuery.disableAnimationsOf(context) ||
        !context.motion.animatesEntrances) {
      return;
    }
    unawaited(_controller.forward());
  }

  void _release() {
    if (_controller.value > 0) unawaited(_controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onTapDown: onTap == null ? null : (_) => _press(),
      onTapUp: onTap == null ? null : (_) => _release(),
      onTapCancel: onTap == null ? null : _release,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
