import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/core/widgets/inputs/filled_text_field.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/domain/usecases/register_user.dart';
import 'package:jdonuts/module/auth/domain/usecases/save_registration_name.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/registration_name/registration_name_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/device_matrix.dart';
import '../../../helpers/pump_app.dart';

class _MockSaveRegistrationName extends Mock implements SaveRegistrationName {}

class _MockRegisterUser extends Mock implements RegisterUser {}

void main() {
  late _MockSaveRegistrationName saveName;
  late _MockRegisterUser registerUser;

  setUp(() {
    saveName = _MockSaveRegistrationName();
    registerUser = _MockRegisterUser();
    when(
      () => saveName(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
      ),
    ).thenAnswer((_) async => const Ok(Unit.value));
  });

  Future<RegistrationBloc> pumpScreen(
    WidgetTester tester, {
    VoidCallback? onContinue,
    Size size = const Size(360, 800),
  }) async {
    final bloc = RegistrationBloc(
      saveRegistrationName: saveName,
      registerUser: registerUser,
    );
    await tester.pumpApp(
      RegistrationNameScreen(onContinue: onContinue ?? () {}),
      providers: [BlocProvider<RegistrationBloc>.value(value: bloc)],
      size: size,
      tier: MotionTier.minimal,
    );
    await tester.pump();
    return bloc;
  }

  testWidgets('shows two placeholders without floating labels', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    await pumpScreen(tester);
    expect(find.byType(FilledTextField), findsNWidgets(2));
    expect(find.text(l10n.firstNameLabel), findsOneWidget);
    expect(find.text(l10n.lastNameLabel), findsOneWidget);
    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(
      fields.every(
        (field) =>
            field.decoration?.floatingLabelBehavior !=
            FloatingLabelBehavior.auto,
      ),
      isTrue,
    );
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);
  });

  testWidgets('shows an inline error after blur of an empty first name', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final bloc = await pumpScreen(tester);
    expect(find.text(l10n.firstNameRequired), findsNothing);
    bloc.add(const RegistrationFirstNameFocusChanged(focused: false));
    await tester.pump();
    expect(find.text(l10n.firstNameRequired), findsOneWidget);
  });

  testWidgets('enables Continue for valid names', (tester) async {
    await pumpScreen(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Ye Min');
    await tester.enterText(fields.at(1), 'Phyoe Win');
    await tester.pump();
    expect(
      tester.widget<AppButton>(find.byType(AppButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('moves focus to last name on next', (tester) async {
    await pumpScreen(tester);
    final fields = find.byType(TextField);
    final first = tester.widget<TextField>(fields.at(0));
    final last = tester.widget<TextField>(fields.at(1));
    await tester.tap(fields.at(0));
    await tester.pump();
    first.onSubmitted?.call('Ye');
    await tester.pump();
    expect(last.focusNode!.hasFocus, isTrue);
  });

  testWidgets('keeps entered values in the registration draft', (tester) async {
    final bloc = await pumpScreen(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Ye Min');
    await tester.enterText(fields.at(1), 'Phyoe Win');
    await tester.pump();
    expect(bloc.state.firstName, 'Ye Min');
    expect(bloc.state.lastName, 'Phyoe Win');
    expect(
      tester
          .widgetList<EditableText>(find.byType(EditableText))
          .map((field) => field.controller.text)
          .toList(),
      ['Ye Min', 'Phyoe Win'],
    );
  });

  for (final size in [DeviceMatrix.smallPhone, DeviceMatrix.largePhone]) {
    testWidgets('keeps Continue above the keyboard at $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      await pumpScreen(tester, size: size);
      const keyboardHeight = 300.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight);
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(
        tester.getBottomLeft(find.byType(AppButton)).dy,
        lessThan(size.height - keyboardHeight),
      );
    });
  }
}
