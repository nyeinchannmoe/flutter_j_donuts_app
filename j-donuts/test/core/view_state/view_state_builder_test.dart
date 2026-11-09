import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';

import '../../helpers/pump_app.dart';

const Key _skeletonKey = Key('skeleton');

Widget _builder(ViewState<String> state, {VoidCallback? onRetry}) =>
    ViewStateBuilder<String>(
      state: state,
      skeleton: const SizedBox(key: _skeletonKey),
      builder: (context, value) => Text(value),
      emptyMessage: 'Nothing here',
      onRetry: onRetry,
    );

void main() {
  group('ViewStateBuilder', () {
    testWidgets('shows the skeleton while loading', (tester) async {
      await tester.pumpApp(_builder(const ViewState.loading()));

      expect(find.byKey(_skeletonKey), findsOneWidget);
    });

    testWidgets('builds the data', (tester) async {
      await tester.pumpApp(_builder(const ViewState.data('Glazed')));
      await tester.pumpAndSettle();

      expect(find.text('Glazed'), findsOneWidget);
    });

    testWidgets('shows the empty message', (tester) async {
      await tester.pumpApp(_builder(const ViewState.empty()));
      await tester.pumpAndSettle();

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('offers a retry for retryable failures', (tester) async {
      var retries = 0;
      await tester.pumpApp(
        _builder(
          const ViewState.failure(NetworkFailure()),
          onRetry: () => retries++,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextButton));

      expect(retries, 1);
    });

    testWidgets('hides the retry for permanent failures', (tester) async {
      await tester.pumpApp(
        _builder(const ViewState.failure(NotFoundFailure()), onRetry: () {}),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextButton), findsNothing);
    });
  });
}
