import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Drag-driven 3D tilt with a spring back to rest. No sensors are used.
/// Only active when the profile allows depth effects.
class PerspectiveTilt extends StatefulWidget {
  const PerspectiveTilt({required this.child, super.key});

  final Widget child;

  @override
  State<PerspectiveTilt> createState() => _PerspectiveTiltState();
}

class _PerspectiveTiltState extends State<PerspectiveTilt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _release;
  final ValueNotifier<Offset> _tilt = ValueNotifier(Offset.zero);
  Offset _releaseFrom = Offset.zero;

  @override
  void initState() {
    super.initState();
    _release = AnimationController(vsync: this)..addListener(_onRelease);
  }

  void _onDragUpdate(DragUpdateDetails details, Size size) {
    _release.stop();
    final next =
        _tilt.value +
        Offset(
          details.delta.dx / size.width * MotionTokens.maxTilt * 2,
          details.delta.dy / size.height * MotionTokens.maxTilt * 2,
        );
    _tilt.value = Offset(
      next.dx.clamp(-MotionTokens.maxTilt, MotionTokens.maxTilt),
      next.dy.clamp(-MotionTokens.maxTilt, MotionTokens.maxTilt),
    );
  }

  void _onDragEnd() {
    _releaseFrom = _tilt.value;
    _release.duration = context.motion.scaleDuration(MotionTokens.emphasized);
    unawaited(_release.forward(from: 0));
  }

  void _onRelease() {
    final t = MotionTokens.spring.transform(_release.value);
    _tilt.value = Offset.lerp(_releaseFrom, Offset.zero, t)!;
  }

  @override
  void dispose() {
    _release.dispose();
    _tilt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!context.motion.allowsDepthEffects) return widget.child;
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onPanUpdate: (details) => _onDragUpdate(details, constraints.biggest),
        onPanEnd: (_) => _onDragEnd(),
        onPanCancel: _onDragEnd,
        child: ValueListenableBuilder<Offset>(
          valueListenable: _tilt,
          builder: (context, tilt, child) => Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, MotionTokens.perspectiveDepth)
              ..rotateX(-tilt.dy)
              ..rotateY(tilt.dx),
            child: child,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
