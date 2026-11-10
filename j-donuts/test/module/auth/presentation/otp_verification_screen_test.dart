import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/domain/entities/otp_verification.dart';
import 'package:jdonuts/module/auth/domain/usecases/request_otp.dart';
import 'package:jdonuts/module/auth/domain/usecases/verify_otp.dart';
import 'package:jdonuts/module/auth/presentation/bloc/otp_verification/otp_verification_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/otp_verification/otp_verification_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_clock.dart';
import '../../../helpers/fake_interval_ticker.dart';
import '../../../helpers/pump_app.dart';

class _MockRequestOtp extends Mock implements RequestOtp {}

class _MockVerifyOtp extends Mock implements VerifyOtp {}

const _phone = '+959254135592';

void main() {
  late _MockVerifyOtp verifyOtp;
  late _MockRequestOtp requestOtp;
  late FakeClock clock;
  late FakeIntervalTicker ticker;

  setUp(() {
    verifyOtp = _MockVerifyOtp();
    requestOtp = _MockRequestOtp();
    clock = FakeClock(DateTime(2026, 11, 10, 12));
    ticker = FakeIntervalTicker();
    when(
      () => verifyOtp(
        phoneE164: any(named: 'phoneE164'),
        code: any(named: 'code'),
      ),
    ).thenAnswer(
      (_) async => const Ok(OtpVerification(isRegistered: false)),
    );
    when(() => requestOtp(any())).thenAnswer((_) async => const Ok(Unit.value));
  });

  tearDown(() async => ticker.dispose());

  OtpVerificationBloc buildBloc() => OtpVerificationBloc(
    verifyOtp: verifyOtp,
    requestOtp: requestOtp,
    clock: clock,
    ticker: ticker,
  );

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpApp(
      OtpVerificationScreen(
        phoneE164: _phone,
        onNewMemberVerified: () {},
      ),
      providers: [
        BlocProvider<OtpVerificationBloc>(
          create: (_) => buildBloc()
            ..add(const OtpVerificationStarted(phoneE164: _phone)),
        ),
      ],
      size: const Size(360, 800),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('shows the phone in the subtitle and has no Continue button', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    await pumpScreen(tester);

    expect(find.text(l10n.otpSubtitle(_phone)), findsOneWidget);
    expect(find.byType(AppButton), findsNothing);
    expect(find.text(l10n.actionContinue), findsNothing);
  });

  testWidgets('shows an error under the boxes for a wrong code', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    when(
      () => verifyOtp(
        phoneE164: any(named: 'phoneE164'),
        code: any(named: 'code'),
      ),
    ).thenAnswer(
      (_) async => const Err(AuthFailure(code: FailureCodes.invalidCode)),
    );
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), '000000');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text(l10n.failureInvalidOtp), findsOneWidget);
  });

  testWidgets('shows the resend countdown and Resend action', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));
    await pumpScreen(tester);

    expect(find.textContaining(l10n.otpDidNotReceive), findsOneWidget);
    expect(find.textContaining('5:00'), findsOneWidget);
    expect(find.text(l10n.otpResendAction), findsNothing);

    final bloc = tester.element(find.byType(OtpVerificationScreen))
        .read<OtpVerificationBloc>();
    clock.advance(const Duration(minutes: 5));
    ticker.emit();
    await tester.pump();

    expect(bloc.state.canResend, isTrue);
    expect(find.text(l10n.otpResendAction), findsOneWidget);
  });

  testWidgets('back keeps the phone number on the route callback', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.textContaining(_phone), findsOneWidget);
    final back = find.byTooltip('Back');
    expect(back, findsOneWidget);
  });
}
