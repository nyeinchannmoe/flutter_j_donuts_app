import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/widgets/inputs/segmented_code_field.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('auto-advances digits and reports completion', (tester) async {
    final value = ValueNotifier('');
    var completed = '';
    addTearDown(value.dispose);
    await tester.pumpApp(
      ValueListenableBuilder<String>(
        valueListenable: value,
        builder: (context, current, _) => SegmentedCodeField(
          length: 6,
          value: current,
          hasError: false,
          enabled: true,
          isLoading: false,
          shakeEpoch: 0,
          semanticsLabel:
              'Verification code, ${current.length} of 6 digits entered',
          onChanged: (next) => value.value = next,
          onCompleted: (next) => completed = next,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(value.value, '123456');
    expect(completed, '123456');
  });

  testWidgets('backspace clears the previous digit', (tester) async {
    final value = ValueNotifier('12');
    addTearDown(value.dispose);
    await tester.pumpApp(
      ValueListenableBuilder<String>(
        valueListenable: value,
        builder: (context, current, _) => SegmentedCodeField(
          length: 6,
          value: current,
          hasError: false,
          enabled: true,
          isLoading: false,
          shakeEpoch: 0,
          semanticsLabel: 'code',
          onChanged: (next) => value.value = next,
          onCompleted: (_) {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '1');
    await tester.pump();
    expect(value.value, '1');
  });

  testWidgets('paste fills all digits and strips extras', (tester) async {
    final value = ValueNotifier('');
    addTearDown(value.dispose);
    await tester.pumpApp(
      ValueListenableBuilder<String>(
        valueListenable: value,
        builder: (context, current, _) => SegmentedCodeField(
          length: 6,
          value: current,
          hasError: false,
          enabled: true,
          isLoading: false,
          shakeEpoch: 0,
          semanticsLabel: 'code',
          onChanged: (next) => value.value = next,
          onCompleted: (_) {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '12a3456789');
    await tester.pump();
    expect(value.value, '123456');
  });

  testWidgets('locked state disables the hidden field', (tester) async {
    await tester.pumpApp(
      const SegmentedCodeField(
        length: 6,
        value: '',
        hasError: false,
        enabled: false,
        isLoading: false,
        shakeEpoch: 0,
        semanticsLabel: 'code',
        onChanged: _noop,
        onCompleted: _noop,
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.enabled, isFalse);
  });

  testWidgets('reduced motion still shows an error border', (tester) async {
    await tester.pumpApp(
      const SegmentedCodeField(
        length: 6,
        value: '',
        hasError: true,
        enabled: true,
        isLoading: false,
        shakeEpoch: 1,
        semanticsLabel: 'code',
        onChanged: _noop,
        onCompleted: _noop,
      ),
      tier: MotionTier.minimal,
    );
    await tester.pump();
    expect(find.byType(AnimatedContainer), findsWidgets);
  });
}

void _noop(String value) {}
