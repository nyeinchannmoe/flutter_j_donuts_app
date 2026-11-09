import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Rolls a number vertically when it changes: up for increases, down for
/// decreases. The minimal tier cross-fades.
class AnimatedQuantityText extends StatefulWidget {
  const AnimatedQuantityText({required this.value, this.style, super.key});

  final int value;
  final TextStyle? style;

  @override
  State<AnimatedQuantityText> createState() => _AnimatedQuantityTextState();
}

class _AnimatedQuantityTextState extends State<AnimatedQuantityText> {
  late int _previous = widget.value;
  bool _increasing = true;

  @override
  void didUpdateWidget(AnimatedQuantityText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;
    _increasing = widget.value > _previous;
    _previous = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.motion;
    return AnimatedSwitcher(
      duration: profile.scaleDuration(MotionTokens.fast),
      switchInCurve: MotionTokens.decelerate,
      switchOutCurve: MotionTokens.accelerate,
      transitionBuilder: profile.animatesEntrances
          ? _rollTransition
          : AnimatedSwitcher.defaultTransitionBuilder,
      child: Text(
        '${widget.value}',
        key: ValueKey<int>(widget.value),
        style: widget.style,
      ),
    );
  }

  Widget _rollTransition(Widget child, Animation<double> animation) {
    final isIncoming = child.key == ValueKey<int>(widget.value);
    final direction = _increasing ? 1.0 : -1.0;
    final begin = Offset(0, isIncoming ? direction : -direction);
    return ClipRect(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}
