import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Counts from the previous value (zero on first build) up to [value].
/// The minimal tier shows the final value immediately.
class CountUpText extends StatelessWidget {
  const CountUpText({
    required this.value,
    required this.format,
    this.style,
    super.key,
  });

  final int value;
  final String Function(int value) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final profile = context.motion;
    if (!profile.animatesEntrances) {
      return Text(format(value), style: style);
    }
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: profile.scaleDuration(MotionTokens.countUp),
      curve: MotionTokens.decelerate,
      builder: (context, current, _) => Text(format(current), style: style),
    );
  }
}
