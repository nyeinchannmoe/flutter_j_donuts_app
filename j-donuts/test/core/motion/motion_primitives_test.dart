import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/motion/primitives/fade_slide_in.dart';
import 'package:jdonuts/core/motion/primitives/pop_in.dart';
import 'package:jdonuts/core/motion/primitives/shake_on_trigger.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/widgets/buttons/pressable_scale.dart';

import '../../helpers/pump_app.dart';

const Key _childKey = Key('child');

Offset _translationAbove(WidgetTester tester, Type primitive) {
  final transform = tester.widget<Transform>(
    find
        .ancestor(of: find.byKey(_childKey), matching: find.byType(Transform))
        .first,
  );
  final translation = transform.transform.getTranslation();
  expect(find.byType(primitive), findsOneWidget);
  return Offset(translation.x, translation.y);
}

void main() {
  group('FadeSlideIn', () {
    testWidgets('slides in from below on the full tier', (tester) async {
      await tester.pumpApp(
        const FadeSlideIn(child: SizedBox(key: _childKey)),
      );

      expect(_translationAbove(tester, FadeSlideIn).dy, greaterThan(0));
      await tester.pumpAndSettle();
      expect(_translationAbove(tester, FadeSlideIn), Offset.zero);
    });

    testWidgets('only fades on the minimal tier', (tester) async {
      await tester.pumpApp(
        const FadeSlideIn(child: SizedBox(key: _childKey)),
        tier: MotionTier.minimal,
      );

      expect(_translationAbove(tester, FadeSlideIn), Offset.zero);
      await tester.pumpAndSettle();
      expect(find.byKey(_childKey), findsOneWidget);
    });
  });

  group('StaggeredEntrance', () {
    Widget list() => const StaggeredEntrance(
      itemCount: 3,
      child: Column(
        children: [
          StaggeredItem(index: 0, child: Text('a')),
          StaggeredItem(index: 1, child: Text('b')),
          StaggeredItem(index: 2, child: Text('c', key: _childKey)),
        ],
      ),
    );

    testWidgets('animates items on the full tier', (tester) async {
      await tester.pumpApp(list());

      expect(
        find.ancestor(
          of: find.byKey(_childKey),
          matching: find.byType(FadeTransition),
        ),
        findsWidgets,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('renders items unchanged on the minimal tier', (tester) async {
      await tester.pumpApp(list(), tier: MotionTier.minimal);

      expect(
        find.descendant(
          of: find.byType(StaggeredItem),
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
      );
    });
  });

  group('PopIn', () {
    testWidgets('shows the child at full scale after settling', (
      tester,
    ) async {
      await tester.pumpApp(const PopIn(child: SizedBox(key: _childKey)));

      await tester.pumpAndSettle();

      final scale = tester.widget<ScaleTransition>(
        find
            .ancestor(
              of: find.byKey(_childKey),
              matching: find.byType(ScaleTransition),
            )
            .first,
      );
      expect(scale.scale.value, 1);
    });

    testWidgets('appears immediately on the minimal tier', (tester) async {
      await tester.pumpApp(
        const PopIn(child: SizedBox(key: _childKey)),
        tier: MotionTier.minimal,
      );

      final scale = tester.widget<ScaleTransition>(
        find
            .ancestor(
              of: find.byKey(_childKey),
              matching: find.byType(ScaleTransition),
            )
            .first,
      );
      expect(scale.scale.value, 1);
    });
  });

  group('PressableScale', () {
    testWidgets('reports taps', (tester) async {
      var taps = 0;
      await tester.pumpApp(
        Center(
          child: PressableScale(
            onTap: () => taps++,
            child: const SizedBox.square(dimension: 48, key: _childKey),
          ),
        ),
      );

      await tester.tap(find.byKey(_childKey));
      await tester.pumpAndSettle();

      expect(taps, 1);
    });

    testWidgets('ignores taps without a callback', (tester) async {
      await tester.pumpApp(
        const Center(
          child: PressableScale(
            child: SizedBox.square(dimension: 48, key: _childKey),
          ),
        ),
      );

      await tester.tap(find.byKey(_childKey), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });

  group('ShakeOnTrigger', () {
    Widget shaker(int trigger) => ShakeOnTrigger(
      trigger: trigger,
      child: const SizedBox(key: _childKey),
    );

    testWidgets('shakes when the trigger changes', (tester) async {
      await tester.pumpApp(shaker(0));
      await tester.pumpApp(shaker(1));

      await tester.pump(const Duration(milliseconds: 60));

      expect(_translationAbove(tester, ShakeOnTrigger).dx, isNot(0));
      await tester.pumpAndSettle();
      expect(_translationAbove(tester, ShakeOnTrigger), Offset.zero);
    });

    testWidgets('stays still on the minimal tier', (tester) async {
      await tester.pumpApp(shaker(0), tier: MotionTier.minimal);
      await tester.pumpApp(shaker(1), tier: MotionTier.minimal);

      await tester.pump(const Duration(milliseconds: 60));

      expect(_translationAbove(tester, ShakeOnTrigger), Offset.zero);
    });
  });
}
