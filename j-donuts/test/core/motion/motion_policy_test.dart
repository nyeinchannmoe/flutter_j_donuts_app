import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/frame_budget_monitor.dart';
import 'package:jdonuts/core/motion/motion_policy.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

import '../../helpers/test_doubles.dart';

void main() {
  group('MotionPolicy', () {
    test('the platform reduce-motion setting forces the minimal tier', () {
      final policy = MotionPolicy();
      addTearDown(policy.dispose);

      expect(policy.resolve(disableAnimations: true).tier, MotionTier.minimal);
      expect(policy.resolve(disableAnimations: false).tier, MotionTier.full);
    });

    test('jank steps down one tier at a time and never back up', () {
      var notifications = 0;
      final policy = MotionPolicy()..addListener(() => notifications++);
      addTearDown(policy.dispose);

      policy
        ..downgradeForJank()
        ..downgradeForJank()
        ..downgradeForJank();

      expect(policy.ceiling, MotionTier.minimal);
      expect(notifications, 2);
    });

    test('ambient motion pauses while the app is in the background', () {
      final policy = MotionPolicy();
      addTearDown(policy.dispose);

      policy.updateAppActive(isActive: false);

      final profile = policy.resolve(disableAnimations: false);
      expect(profile.allowsAmbient, isFalse);
      expect(profile.animatesEntrances, isTrue);
    });
  });

  group('MotionProfile', () {
    const duration = Duration(milliseconds: 400);

    test('scales durations per tier', () {
      expect(MotionProfile.full.scaleDuration(duration), duration);
      expect(
        const MotionProfile(tier: MotionTier.reduced).scaleDuration(duration),
        duration * MotionTokens.reducedDurationFactor,
      );
      expect(
        MotionProfile.minimal.scaleDuration(duration),
        MotionTokens.minimalFade,
      );
    });

    test('minimal disables entrances, depth and stagger', () {
      const profile = MotionProfile.minimal;

      expect(profile.animatesEntrances, isFalse);
      expect(profile.allowsDepthEffects, isFalse);
      expect(profile.maxStaggerItems, 0);
    });
  });

  group('FrameBudgetMonitor', () {
    const slow = Duration(milliseconds: 40);
    const fast = Duration(milliseconds: 8);

    FrameBudgetMonitor buildMonitor(void Function() onJank) =>
        FrameBudgetMonitor(logger: silentLogger(), windowSize: 4)
          ..onSustainedJank = onJank;

    void record(FrameBudgetMonitor monitor, List<Duration> frames) =>
        frames.forEach(monitor.recordFrame);

    test('attach is a no-op in debug so timings cannot downgrade the tier', () {
      final monitor = FrameBudgetMonitor(logger: silentLogger())
        ..attach();

      expect(monitor.isAttached, isFalse);
    });

    test('one janky window is not enough to downgrade', () {
      var reports = 0;
      final monitor = buildMonitor(() => reports++);

      record(monitor, [slow, slow, slow, slow]);

      expect(reports, 0);
    });

    test('a smooth window resets the janky streak', () {
      var reports = 0;
      final monitor = buildMonitor(() => reports++);

      record(monitor, [slow, slow, slow, slow, fast, fast, fast, fast]);
      record(monitor, [slow, slow, slow, slow]);

      expect(reports, 0);
    });

    test('consecutive janky windows report once per session', () {
      var reports = 0;
      final monitor = buildMonitor(() => reports++);

      record(monitor, List.filled(16, slow));

      expect(reports, 1);
    });
  });
}
