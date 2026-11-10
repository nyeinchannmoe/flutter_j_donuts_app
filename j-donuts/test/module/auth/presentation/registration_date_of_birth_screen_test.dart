import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/motion/painters/check_morph_painter.dart';
import 'package:jdonuts/core/motion/primitives/morphing_progress_ring.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/core/widgets/inputs/filled_text_field.dart';
import 'package:jdonuts/core/widgets/legal_footer.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/entities/user_profile.dart';
import 'package:jdonuts/module/auth/domain/usecases/register_user.dart';
import 'package:jdonuts/module/auth/domain/usecases/save_registration_name.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/registration_date_of_birth/registration_date_of_birth_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_clock.dart';
import '../../../helpers/pump_app.dart';

class _MockSaveRegistrationName extends Mock implements SaveRegistrationName {}

class _MockRegisterUser extends Mock implements RegisterUser {}

void main() {
  late _MockSaveRegistrationName saveName;
  late _MockRegisterUser registerUser;
  late FakeClock clock;
  final today = DateTime(2026, 11, 10);

  setUp(() {
    saveName = _MockSaveRegistrationName();
    registerUser = _MockRegisterUser();
    clock = FakeClock(today);
    registerFallbackValue(
      RegistrationDetails(firstName: 'Su', dateOfBirth: DateTime(2000)),
    );
  });

  Future<RegistrationBloc> pumpScreen(
    WidgetTester tester, {
    MotionTier tier = MotionTier.minimal,
    VoidCallback? onRegistered,
  }) async {
    final bloc = RegistrationBloc(
      saveRegistrationName: saveName,
      registerUser: registerUser,
      clock: clock,
    );
    await tester.pumpApp(
      RegistrationDateOfBirthScreen(
        onRegistered: onRegistered ?? () {},
        clock: clock,
      ),
      providers: [BlocProvider<RegistrationBloc>.value(value: bloc)],
      tier: tier,
    );
    await tester.pump();
    return bloc;
  }

  Future<void> fillValidDraft(
    WidgetTester tester,
    RegistrationBloc bloc,
  ) async {
    bloc
      ..add(const RegistrationFirstNameChanged('Ye Min'))
      ..add(const RegistrationLastNameChanged('Phyoe Win'));
    await tester.pump();
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('May'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), '1');
    await tester.enterText(fields.at(2), '2000');
    await tester.pump();
  }

  testWidgets('shows three placeholders without floating labels', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    await pumpScreen(tester);
    expect(find.byType(FilledTextField), findsNWidgets(3));
    expect(find.text(l10n.dobMonthLabel), findsOneWidget);
    expect(find.text(l10n.dobDayLabel), findsOneWidget);
    expect(find.text(l10n.dobYearLabel), findsOneWidget);
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
    expect(find.byType(LegalFooter), findsOneWidget);
  });

  testWidgets('opens the month sheet and moves focus to Day', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    await pumpScreen(tester);
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    expect(find.text(l10n.dobMonthSheetTitle), findsOneWidget);
    await tester.tap(find.text('May'));
    await tester.pumpAndSettle();
    expect(find.text('May'), findsOneWidget);
    final dayField = tester.widget<TextField>(find.byType(TextField).at(1));
    expect(dayField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('shows an inline message for an invalid date', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    await pumpScreen(tester);
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('April'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(1), '31');
    await tester.enterText(fields.at(2), '2001');
    await tester.pump();
    expect(find.text(l10n.dobErrorNotReal), findsOneWidget);
    expect(tester.widget<AppButton>(find.byType(AppButton)).onPressed, isNull);
  });

  testWidgets('enables Continue for a valid date', (tester) async {
    final bloc = await pumpScreen(tester);
    await fillValidDraft(tester, bloc);
    expect(
      tester.widget<AppButton>(find.byType(AppButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('shows the check immediately with reduced motion', (
    tester,
  ) async {
    await pumpScreen(tester);
    final ring = find.byType(MorphingProgressRing);
    final paint = tester.widget<CustomPaint>(
      find.descendant(of: ring, matching: find.byType(CustomPaint)),
    );
    final check = paint.foregroundPainter! as CheckMorphPainter;
    expect(check.progress.value, 1);
  });

  testWidgets('back keeps the entered values in the draft', (tester) async {
    final bloc = await pumpScreen(tester);
    await fillValidDraft(tester, bloc);
    expect(bloc.state.month, 5);
    expect(bloc.state.dayText, '1');
    expect(bloc.state.yearText, '2000');
  });

  testWidgets('Continue loading calls register once', (tester) async {
    when(() => registerUser(any())).thenAnswer(
      (_) async => Ok(
        UserProfile(
          id: 'u_1',
          phoneE164: '+959123456789',
          firstName: 'Ye Min',
          dateOfBirth: DateTime(2000, 5),
        ),
      ),
    );
    var registered = false;
    final bloc = await pumpScreen(
      tester,
      onRegistered: () => registered = true,
    );
    await fillValidDraft(tester, bloc);
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    await tester.pump();
    expect(registered, isTrue);
    verify(() => registerUser(any())).called(1);
  });
}
