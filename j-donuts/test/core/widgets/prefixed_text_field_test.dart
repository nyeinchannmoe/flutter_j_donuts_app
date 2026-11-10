import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/widgets/inputs/prefixed_text_field.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('animates focus and error around a fixed prefix', (tester) async {
    final error = ValueNotifier<String?>(null);
    addTearDown(error.dispose);
    await tester.pumpApp(
      Scaffold(
        body: ValueListenableBuilder<String?>(
          valueListenable: error,
          builder: (context, message, child) => PrefixedTextField(
            label: 'Account',
            prefix: '+95',
            errorText: message,
          ),
        ),
      ),
      tier: MotionTier.minimal,
    );
    await tester.pump();

    final field = find.byType(PrefixedTextField);
    final colors = tester.element(field).colors;
    Color border() {
      final frame = tester.widget<AnimatedContainer>(
        find.descendant(of: field, matching: find.byType(AnimatedContainer)),
      );
      final decoration = frame.decoration! as BoxDecoration;
      return (decoration.border! as Border).top.color;
    }

    expect(border().a, 0);
    await tester.enterText(find.byType(TextField), '9123');
    await tester.pump();
    expect(border(), colors.primary);
    expect(find.text('+95'), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '9123',
    );

    error.value = 'Invalid account';
    await tester.pump();
    expect(border(), colors.danger);
    expect(find.text('Invalid account'), findsOneWidget);
  });
}
