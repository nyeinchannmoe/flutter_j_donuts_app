import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/widgets/inputs/filled_text_field.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('animates focus and error without a floating label', (
    tester,
  ) async {
    final error = ValueNotifier<String?>(null);
    addTearDown(error.dispose);
    await tester.pumpApp(
      Scaffold(
        body: ValueListenableBuilder<String?>(
          valueListenable: error,
          builder: (context, message, child) => FilledTextField(
            label: 'First Name',
            errorText: message,
          ),
        ),
      ),
      tier: MotionTier.minimal,
    );
    await tester.pump();

    final field = find.byType(FilledTextField);
    final colors = tester.element(field).colors;
    Color border() {
      final frame = tester.widget<AnimatedContainer>(
        find.descendant(of: field, matching: find.byType(AnimatedContainer)),
      );
      final decoration = frame.decoration! as BoxDecoration;
      return (decoration.border! as Border).top.color;
    }

    expect(find.text('First Name'), findsOneWidget);
    expect(border().a, 0);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(border(), colors.primary);

    error.value = 'Required';
    await tester.pump();
    expect(border(), colors.danger);
    expect(find.text('Required'), findsOneWidget);
  });
}
