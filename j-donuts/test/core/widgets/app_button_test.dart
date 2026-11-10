import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('shares the filled button style and distinguishes disabled', (
      tester,
    ) async {
      for (final enabled in [true, false]) {
        await tester.pumpApp(
          Center(
            child: AppButton(
              label: 'Continue',
              onPressed: enabled ? () {} : null,
            ),
          ),
        );
        final button = find.byType(AppButton);
        final colors = tester.element(button).colors;
        final surface = find.descendant(
          of: button,
          matching: find.byType(DecoratedBox),
        );
        final decoration =
            tester.widget<DecoratedBox>(surface).decoration as ShapeDecoration;
        expect(tester.getSize(surface).height, 52);
        expect(
          tester.widget<Text>(find.text('CONTINUE')).style?.color,
          colors.onPrimary,
        );
        if (enabled) {
          expect(decoration.color, colors.primary);
        } else {
          expect(decoration.color, isNot(colors.primary));
        }
      }
    });

    testWidgets('can use the primary hue for the disabled fill', (
      tester,
    ) async {
      await tester.pumpApp(
        const AppButton(
          label: 'Continue',
          onPressed: null,
          usePrimaryDisabledFill: true,
        ),
      );
      final button = find.byType(AppButton);
      final context = tester.element(button);
      final fill = FilledButtonTheme.of(context).style!.backgroundColor!;
      final surface = tester.widget<DecoratedBox>(
        find.descendant(of: button, matching: find.byType(DecoratedBox)),
      );
      expect(
        (surface.decoration as ShapeDecoration).color,
        context.colors.primary.withValues(
          alpha: fill.resolve({WidgetState.disabled})!.a,
        ),
      );
    });
    testWidgets('ignores taps while an async action runs', (tester) async {
      final pending = Completer<void>();
      var taps = 0;
      await tester.pumpApp(
        Center(
          child: AppButton(
            label: 'Continue',
            onPressed: () {
              taps++;
              return pending.future;
            },
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pump();
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(taps, 1);
      expect(find.byKey(AppButton.progressKey), findsOneWidget);
      pending.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(AppButton.progressKey), findsNothing);
    });

    testWidgets('shows progress and ignores taps while loading', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpApp(
        Center(
          child: AppButton(
            label: 'Continue',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(taps, 0);
      expect(find.byKey(AppButton.progressKey), findsOneWidget);
    });

    testWidgets('is disabled without a callback', (tester) async {
      await tester.pumpApp(
        const Center(child: AppButton(label: 'Continue', onPressed: null)),
      );

      expect(
        tester.getSemantics(find.byType(AppButton)),
        isSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
    });
  });
}
