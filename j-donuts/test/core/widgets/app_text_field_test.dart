import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/widgets/inputs/app_text_field.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('renders a labeled field before focus and with an error', (
    tester,
  ) async {
    final error = ValueNotifier<String?>(null);
    addTearDown(error.dispose);
    await tester.pumpApp(
      Scaffold(
        body: ValueListenableBuilder<String?>(
          valueListenable: error,
          builder: (context, message, child) => AppTextField(
            label: 'Verification code',
            errorText: message,
          ),
        ),
      ),
    );

    expect(find.text('Verification code'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), '123456');
    await tester.pumpAndSettle();
    error.value = 'Invalid code';
    await tester.pumpAndSettle();

    expect(find.text('Invalid code'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
