import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Indexed stack for tab branches. The selected tab fades and scales in;
/// unselected tabs keep their state but have their tickers disabled.
///
/// The widget structure around each child never changes, so switching
/// tabs or motion tiers never remounts a branch navigator.
class FadeThroughTabStack extends StatefulWidget {
  const FadeThroughTabStack({
    required this.currentIndex,
    required this.children,
    super.key,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<FadeThroughTabStack> createState() => _FadeThroughTabStackState();
}

class _FadeThroughTabStackState extends State<FadeThroughTabStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: 1,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: MotionTokens.decelerate,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: MotionTokens.fadeThroughStartScale,
    end: 1,
  ).animate(_curve);

  @override
  void didUpdateWidget(FadeThroughTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) return;
    final profile = context.motion;
    if (!profile.animatesEntrances) {
      _controller.value = 1;
      return;
    }
    _controller.duration = profile.scaleDuration(MotionTokens.standard);
    unawaited(_controller.forward(from: 0));
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IndexedStack(
    index: widget.currentIndex,
    sizing: StackFit.expand,
    children: [
      for (var i = 0; i < widget.children.length; i++)
        TickerMode(
          enabled: i == widget.currentIndex,
          child: FadeTransition(
            opacity: i == widget.currentIndex
                ? _curve
                : kAlwaysCompleteAnimation,
            child: ScaleTransition(
              scale: i == widget.currentIndex
                  ? _scale
                  : kAlwaysCompleteAnimation,
              child: widget.children[i],
            ),
          ),
        ),
    ],
  );
}
