import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/primitives/stagger_schedule.dart';
import 'package:jdonuts/core/responsive/layout_metrics.dart';

/// Owns the single controller for a staggered entrance. Descendant
/// [StaggeredItem]s read their slot from it, wherever they are in the tree.
///
/// The entrance runs once when this widget is first inserted.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    required this.itemCount,
    required this.child,
    super.key,
  });

  final int itemCount;
  final Widget child;

  /// Lets a painter join the entrance without creating another controller.
  static Animation<double> animationFor(BuildContext context, int index) {
    final scope = context.dependOnInheritedWidgetOfExactType<_StaggerScope>();
    if (scope == null || !scope.schedule.isAnimated) {
      return kAlwaysCompleteAnimation;
    }
    return scope.animation.drive(
      CurveTween(curve: scope.schedule.intervalFor(index)),
    );
  }

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
  );
  StaggerSchedule? _schedule;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickersEnabled = TickerMode.valuesOf(context).enabled;
    if (_schedule == null) {
      final profile = context.motion;
      final schedule = StaggerSchedule(
        itemCount: widget.itemCount,
        maxItems: MediaQuery.disableAnimationsOf(context)
            ? 0
            : profile.maxStaggerItems,
      );
      _schedule = schedule;
      _controller.duration = profile.scaleDuration(schedule.totalDuration);
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _started = true;
      return;
    }
    if (_started || !tickersEnabled) return;
    _started = true;
    if (_schedule!.isAnimated) {
      unawaited(_controller.forward());
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _StaggerScope(
    animation: _controller,
    schedule: _schedule!,
    child: widget.child,
  );
}

class _StaggerScope extends InheritedWidget {
  const _StaggerScope({
    required this.animation,
    required this.schedule,
    required super.child,
  });

  final Animation<double> animation;
  final StaggerSchedule schedule;

  @override
  bool updateShouldNotify(_StaggerScope oldWidget) =>
      oldWidget.animation != animation || oldWidget.schedule != schedule;
}

/// Fades and slides [child] in during slot [index] of the nearest
/// [StaggeredEntrance]. Renders [child] unchanged when there is none.
class StaggeredItem extends StatefulWidget {
  const StaggeredItem({
    required this.index,
    required this.child,
    this.horizontalDrift = false,
    super.key,
  });

  final int index;
  final bool horizontalDrift;
  final Widget child;

  @override
  State<StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<StaggeredItem> {
  CurvedAnimation? _animation;
  Animation<Offset>? _offset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = context.dependOnInheritedWidgetOfExactType<_StaggerScope>();
    _animation?.dispose();
    _animation = null;
    if (scope == null || !scope.schedule.isAnimated) return;
    final animation = CurvedAnimation(
      parent: scope.animation,
      curve: scope.schedule.intervalFor(widget.index),
    );
    final travel =
        MotionTokens.travelMedium * LayoutMetrics.of(context).motionScale;
    _animation = animation;
    _offset = Tween<Offset>(
      begin: Offset(widget.horizontalDrift ? -travel : 0, travel),
      end: Offset.zero,
    ).animate(animation);
  }

  @override
  void dispose() {
    _animation?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _animation;
    final offset = _offset;
    if (animation == null || offset == null) return widget.child;
    return FadeTransition(
      opacity: animation,
      child: AnimatedBuilder(
        animation: offset,
        builder: (context, child) =>
            Transform.translate(offset: offset.value, child: child),
        child: widget.child,
      ),
    );
  }
}
