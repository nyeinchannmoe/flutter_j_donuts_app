import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Derives one Interval per item from a single controller timeline.
///
/// Items beyond `maxItems` share the last slot so long lists never stretch
/// the entrance.
class StaggerSchedule {
  StaggerSchedule({
    required int itemCount,
    required int maxItems,
    this.itemDuration = MotionTokens.entrance,
    this.step = MotionTokens.staggerStep,
    this.curve = MotionTokens.decelerate,
  }) : animatedCount = min(itemCount, maxItems);

  final int animatedCount;
  final Duration itemDuration;
  final Duration step;
  final Curve curve;

  bool get isAnimated => animatedCount > 0;

  Duration get totalDuration => itemDuration + step * max(animatedCount - 1, 0);

  Interval intervalFor(int index) {
    if (!isAnimated) return Interval(1, 1, curve: curve);
    final slot = min(index, animatedCount - 1);
    final total = totalDuration.inMicroseconds;
    final start = (step * slot).inMicroseconds / total;
    final end = (step * slot + itemDuration).inMicroseconds / total;
    return Interval(start, min(end, 1), curve: curve);
  }
}
