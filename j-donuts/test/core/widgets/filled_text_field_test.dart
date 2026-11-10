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

  testWidgets('supports a read-only choice field without a cursor', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpApp(
      Scaffold(
        body: FilledTextField(
          label: 'Month',
          readOnly: true,
          showCursor: false,
          enableInteractiveSelection: false,
          hasError: true,
          onTap: () => tapped = true,
        ),
      ),
      tier: MotionTier.minimal,
    );
    await tester.pump();
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.showCursor, isFalse);
    expect(field.readOnly, isTrue);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(tapped, isTrue);
    final frame = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(FilledTextField),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = frame.decoration! as BoxDecoration;
    final colors = tester.element(find.byType(FilledTextField)).colors;
    expect((decoration.border! as Border).top.color, colors.danger);
  });
}
