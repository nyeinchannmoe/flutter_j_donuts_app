import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Pill that slides behind [slotCount] equal-width slots to [selectedIndex].
/// Place it in a Stack under the slot labels.
class SlidingPillIndicator extends StatelessWidget {
  const SlidingPillIndicator({
    required this.slotCount,
    required this.selectedIndex,
    required this.pill,
    super.key,
  });

  final int slotCount;
  final int selectedIndex;
  final Widget pill;

  @override
  Widget build(BuildContext context) {
    final profile = context.motion;
    final x = slotCount <= 1 ? 0.0 : -1 + 2 * selectedIndex / (slotCount - 1);
    return AnimatedAlign(
      alignment: Alignment(x, 0),
      duration: profile.scaleDuration(MotionTokens.standard),
      curve: MotionTokens.emphasizedCurve,
      child: FractionallySizedBox(widthFactor: 1 / slotCount, child: pill),
    );
  }
}
