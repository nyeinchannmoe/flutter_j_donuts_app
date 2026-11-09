import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppButton', () {
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
