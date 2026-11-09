import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/motion/primitives/animated_quantity_text.dart';
import 'package:jdonuts/core/motion/primitives/count_up_text.dart';
import 'package:jdonuts/core/motion/primitives/morphing_progress_ring.dart';
import 'package:jdonuts/core/motion/primitives/perspective_tilt.dart';
import 'package:jdonuts/core/motion/primitives/pulse_attention.dart';
import 'package:jdonuts/core/motion/primitives/sliding_pill_indicator.dart';
import 'package:jdonuts/core/motion/transitions/fade_through_tab_stack.dart';

import '../../helpers/pump_app.dart';

/// Longer than the minimal fade cap, shorter than any full-tier animation.
const Duration _pastMinimalFade = Duration(milliseconds: 150);
const Key _childKey = Key('child');

/// Rebuilds [builder] with a new value when the test calls `update`.
class _Driver extends StatefulWidget {
  const _Driver({required this.builder});

  final Widget Function(int value) builder;

  @override
  State<_Driver> createState() => _DriverState();
}

class _DriverState extends State<_Driver> {
  int value = 0;

  void update(int next) => setState(() => value = next);

  @override
  Widget build(BuildContext context) => widget.builder(value);
}

Future<void> _pumpDriver(
  WidgetTester tester,
  Widget Function(int value) builder, {
  MotionTier tier = MotionTier.full,
}) async {
  await tester.pumpApp(_Driver(builder: builder), tier: tier);
  await tester.pumpAndSettle();
}

Future<void> _changeTo(WidgetTester tester, int value) async {
  tester.state<_DriverState>(find.byType(_Driver)).update(value);
  await tester.pump();
  await tester.pump(_pastMinimalFade);
}

void main() {
  group('CountUpText', () {
    Widget counter() => CountUpText(value: 1200, format: (value) => '$value');

    testWidgets('counts up from zero on the full tier', (tester) async {
      await tester.pumpApp(counter());

      expect(find.text('0'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('1200'), findsOneWidget);
    });

    testWidgets('shows the final value on the minimal tier', (tester) async {
      await tester.pumpApp(counter(), tier: MotionTier.minimal);

      expect(find.text('1200'), findsOneWidget);
    });
  });

  group('AnimatedQuantityText', () {
    Widget quantity(int value) => AnimatedQuantityText(value: value + 1);
    Finder rolls() => find.descendant(
      of: find.byType(AnimatedQuantityText),
      matching: find.byType(SlideTransition),
    );

    testWidgets('rolls between values on the full tier', (tester) async {
      await _pumpDriver(tester, quantity);

      await _changeTo(tester, 1);

      expect(rolls(), findsWidgets);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('cross-fades on the minimal tier', (tester) async {
      await _pumpDriver(tester, quantity, tier: MotionTier.minimal);

      await _changeTo(tester, 1);

      expect(rolls(), findsNothing);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('PulseAttention', () {
    Widget pulse() => const PulseAttention(active: true, child: SizedBox());

    testWidgets('pulses while active on the full tier', (tester) async {
      await tester.pumpApp(pulse());
      await tester.pump(_pastMinimalFade);

      expect(tester.hasRunningAnimations, isTrue);
    });

    testWidgets('stays still on the minimal tier', (tester) async {
      await tester.pumpApp(pulse(), tier: MotionTier.minimal);
      await tester.pump(_pastMinimalFade);

      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('SlidingPillIndicator', () {
    Widget indicator(int index) => SlidingPillIndicator(
      slotCount: 3,
      selectedIndex: index,
      pill: const SizedBox.expand(),
    );

    testWidgets('slides to the selected slot on the full tier', (
      tester,
    ) async {
      await _pumpDriver(tester, indicator);

      await _changeTo(tester, 2);

      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      final align = tester.widget<AnimatedAlign>(find.byType(AnimatedAlign));
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('finishes within the fade cap on the minimal tier', (
      tester,
    ) async {
      await _pumpDriver(tester, indicator, tier: MotionTier.minimal);

      await _changeTo(tester, 2);

      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('MorphingProgressRing', () {
    Widget ring(int step) => MorphingProgressRing(
      step: step,
      totalSteps: 4,
      extent: 64,
      trackColor: Colors.grey,
      gradientColors: const [Colors.orange, Colors.pink],
      checkColor: Colors.white,
      completed: step == 4,
    );

    testWidgets('animates each step on the full tier', (tester) async {
      await _pumpDriver(tester, ring);

      await _changeTo(tester, 4);

      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('finishes within the fade cap on the minimal tier', (
      tester,
    ) async {
      await _pumpDriver(tester, ring, tier: MotionTier.minimal);

      await _changeTo(tester, 1);

      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('PerspectiveTilt', () {
    Widget tilt() => const PerspectiveTilt(
      child: SizedBox.square(
        key: _childKey,
        dimension: 120,
        child: ColoredBox(color: Colors.brown),
      ),
    );

    testWidgets('springs back after a drag on the full tier', (tester) async {
      await tester.pumpApp(Center(child: tilt()));

      await tester.drag(find.byKey(_childKey), const Offset(40, 0));
      await tester.pump();
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('renders the child untouched on the minimal tier', (
      tester,
    ) async {
      await tester.pumpApp(Center(child: tilt()), tier: MotionTier.minimal);

      expect(
        find.descendant(
          of: find.byType(PerspectiveTilt),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });
  });

  group('FadeThroughTabStack', () {
    Widget tabs(int index) => FadeThroughTabStack(
      currentIndex: index,
      children: const [Text('first'), Text('second')],
    );

    bool tickerEnabled(WidgetTester tester, String label) => tester
        .widget<TickerMode>(
          find
              .ancestor(
                of: find.text(label, skipOffstage: false),
                matching: find.byType(TickerMode, skipOffstage: false),
              )
              .first,
        )
        .enabled;

    testWidgets('fades in the new tab and mutes the old one', (tester) async {
      await _pumpDriver(tester, tabs);

      await _changeTo(tester, 1);

      expect(tester.hasRunningAnimations, isTrue);
      expect(tickerEnabled(tester, 'second'), isTrue);
      expect(tickerEnabled(tester, 'first'), isFalse);
      await tester.pumpAndSettle();
    });

    testWidgets('switches instantly on the minimal tier', (tester) async {
      await _pumpDriver(tester, tabs, tier: MotionTier.minimal);

      tester.state<_DriverState>(find.byType(_Driver)).update(1);
      await tester.pump();

      expect(tester.hasRunningAnimations, isFalse);
      expect(tickerEnabled(tester, 'second'), isTrue);
    });
  });
}
