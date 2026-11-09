import 'package:flutter/foundation.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// How much motion the device and user can afford.
enum MotionTier { full, reduced, minimal }

/// Strategy object that every animation consults before running.
@immutable
class MotionProfile {
  const MotionProfile({required this.tier, this.appActive = true});

  static const MotionProfile full = MotionProfile(tier: MotionTier.full);
  static const MotionProfile minimal = MotionProfile(tier: MotionTier.minimal);

  final MotionTier tier;

  /// False while the app is in the background; ambient motion pauses.
  final bool appActive;

  bool get animatesEntrances => tier != MotionTier.minimal;

  bool get allowsAmbient => tier == MotionTier.full && appActive;

  bool get allowsDepthEffects => tier == MotionTier.full;

  int get maxStaggerItems => switch (tier) {
    MotionTier.full => MotionTokens.maxStaggeredItems,
    MotionTier.reduced => MotionTokens.reducedStaggeredItems,
    MotionTier.minimal => 0,
  };

  /// Full keeps [duration], reduced shortens it, minimal collapses it to a
  /// short fade.
  Duration scaleDuration(Duration duration) => switch (tier) {
    MotionTier.full => duration,
    MotionTier.reduced => duration * MotionTokens.reducedDurationFactor,
    MotionTier.minimal =>
      duration < MotionTokens.minimalFade ? duration : MotionTokens.minimalFade,
  };

  @override
  bool operator ==(Object other) =>
      other is MotionProfile &&
      other.tier == tier &&
      other.appActive == appActive;

  @override
  int get hashCode => Object.hash(tier, appActive);

  @override
  String toString() => 'MotionProfile(${tier.name}, active: $appActive)';
}
