import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Ambient pulse that draws attention to [child] while [active].
///
/// Counts toward the two-ambient-animations budget; it stays still when
/// the profile disallows ambient motion or the app is in the background.
class PulseAttention extends StatefulWidget {
  const PulseAttention({required this.active, required this.child, super.key});

  final bool active;
  final Widget child;

  @override
  State<PulseAttention> createState() => _PulseAttentionState();
}

class _PulseAttentionState extends State<PulseAttention>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionTokens.ambient,
  );
  late final Animation<double> _scale =
      Tween<double>(
        begin: 1,
        end: MotionTokens.pulseScale,
      ).animate(
        CurvedAnimation(parent: _controller, curve: MotionTokens.standardCurve),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(PulseAttention oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final shouldPulse = widget.active && context.motion.allowsAmbient;
    if (shouldPulse && !_controller.isAnimating) {
      unawaited(_controller.repeat(reverse: true));
    } else if (!shouldPulse && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}
