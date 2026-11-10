import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/domain/usecases/check_phone_registered.dart';
import 'package:jdonuts/module/auth/domain/usecases/request_otp.dart';
import 'package:jdonuts/module/auth/presentation/bloc/phone_entry/phone_entry_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/phone_entry/phone_entry_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/device_matrix.dart';
import '../../../helpers/pump_app.dart';

class _MockRequestOtp extends Mock implements RequestOtp {}

class _MockCheckPhoneRegistered extends Mock implements CheckPhoneRegistered {}

PhoneEntryBloc _phoneBloc() => PhoneEntryBloc(
  requestOtp: _MockRequestOtp(),
  checkPhoneRegistered: _MockCheckPhoneRegistered(),
);

void main() {
  testWidgets('validates on blur and keeps the calling code outside input', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.pumpApp(
      PhoneEntryScreen(onCodeSent: (_) {}),
      providers: [
        BlocProvider<PhoneEntryBloc>(create: (_) => _phoneBloc()),
      ],
      size: const Size(360, 800),
    );
    await tester.pumpAndSettle();

    final field = find.byType(TextField);
    AppButton button() => tester.widget<AppButton>(find.byType(AppButton));
    expect(button().onPressed, isNull);

    await tester.enterText(field, '123');
    await tester.pumpAndSettle();
    expect(find.text(l10n.phoneInvalid), findsNothing);
    tester.widget<TextField>(field).focusNode!.unfocus();
    await tester.pumpAndSettle();
    expect(find.text(l10n.phoneInvalid), findsOneWidget);

    await tester.enterText(field, '09254135592');
    await tester.pumpAndSettle();
    expect(find.text(l10n.phoneInvalid), findsNothing);
    expect(button().onPressed, isNotNull);
    expect(find.text(l10n.phoneCountryPrefix), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      '09254135592',
    );
    await tester.enterText(field, '');
    await tester.pumpAndSettle();
    expect(find.text(l10n.phoneCountryPrefix), findsOneWidget);
    expect(button().onPressed, isNull);
  });

  for (final size in [DeviceMatrix.smallPhone, DeviceMatrix.largePhone]) {
    testWidgets('keeps Continue above the keyboard at $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpApp(
        PhoneEntryScreen(onCodeSent: (_) {}),
        providers: [
          BlocProvider<PhoneEntryBloc>(create: (_) => _phoneBloc()),
        ],
        size: size,
        textScale: 1.3,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      const keyboardHeight = 300.0;
      tester.view.viewInsets = const FakeViewPadding(bottom: keyboardHeight);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getBottomLeft(find.byType(AppButton)).dy,
        lessThan(size.height - keyboardHeight),
      );
    });
  }
}
