import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/entities/otp_verification.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/entities/user_profile.dart';
import 'package:jdonuts/module/auth/domain/usecases/register_user.dart';
import 'package:jdonuts/module/auth/domain/usecases/request_otp.dart';
import 'package:jdonuts/module/auth/domain/usecases/save_registration_name.dart';
import 'package:jdonuts/module/auth/domain/usecases/verify_otp.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/presentation/bloc/otp_verification/otp_verification_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/phone_entry/phone_entry_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_clock.dart';
import '../../../helpers/fake_interval_ticker.dart';

class _MockRequestOtp extends Mock implements RequestOtp {}

class _MockVerifyOtp extends Mock implements VerifyOtp {}

class _MockSaveRegistrationName extends Mock implements SaveRegistrationName {}

class _MockRegisterUser extends Mock implements RegisterUser {}

const String _nationalPhone = '9123456789';
const String _phone = '+959123456789';
const AuthFailure _wrongCode = AuthFailure(code: FailureCodes.invalidCode);

void main() {
  group('PhoneEntryBloc', () {
    late _MockRequestOtp requestOtp;
    late Completer<Result<Unit>> pending;

    setUp(() {
      requestOtp = _MockRequestOtp();
      pending = Completer();
    });

    PhoneEntryBloc build() => PhoneEntryBloc(requestOtp: requestOtp);

    blocTest<PhoneEntryBloc, PhoneEntryState>(
      'sends a code for a submitted number',
      setUp: () => when(
        () => requestOtp(_phone),
      ).thenAnswer((_) async => const Ok(Unit.value)),
      build: build,
      act: (bloc) => bloc
        ..add(const PhoneEntryChanged(_nationalPhone))
        ..add(const PhoneEntrySubmitted()),
      expect: () => const [
        PhoneEntryState(phoneE164: _phone),
        PhoneEntryState(phoneE164: _phone, submitting: true),
        PhoneEntryState(phoneE164: _phone, codeSent: true),
      ],
    );

    blocTest<PhoneEntryBloc, PhoneEntryState>(
      'reports a failure when the code cannot be sent',
      setUp: () => when(
        () => requestOtp(_phone),
      ).thenAnswer((_) async => const Err(NetworkFailure())),
      build: build,
      act: (bloc) => bloc
        ..add(const PhoneEntryChanged(_nationalPhone))
        ..add(const PhoneEntrySubmitted()),
      expect: () => const [
        PhoneEntryState(phoneE164: _phone),
        PhoneEntryState(phoneE164: _phone, submitting: true),
        PhoneEntryState(phoneE164: _phone, failure: NetworkFailure()),
      ],
    );

    blocTest<PhoneEntryBloc, PhoneEntryState>(
      'reveals invalid input on blur and ignores invalid submission',
      build: build,
      act: (bloc) => bloc
        ..add(const PhoneEntryChanged('123'))
        ..add(const PhoneEntryFocusChanged(focused: false))
        ..add(const PhoneEntrySubmitted()),
      expect: () => const [
        PhoneEntryState(),
        PhoneEntryState(showInvalid: true),
      ],
      verify: (_) => verifyZeroInteractions(requestOtp),
    );
    blocTest<PhoneEntryBloc, PhoneEntryState>(
      'ignores repeated submits while one is running',
      setUp: () => when(
        () => requestOtp(_phone),
      ).thenAnswer((_) => pending.future),
      build: build,
      act: (bloc) async {
        bloc
          ..add(const PhoneEntryChanged(_nationalPhone))
          ..add(const PhoneEntrySubmitted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PhoneEntrySubmitted());
        await Future<void>.delayed(Duration.zero);
        pending.complete(const Ok(Unit.value));
      },
      verify: (_) => verify(() => requestOtp(_phone)).called(1),
    );
  });

  group('OtpVerificationBloc', () {
    late _MockVerifyOtp verifyOtp;
    late _MockRequestOtp requestOtp;
    late FakeClock clock;
    late FakeIntervalTicker ticker;

    setUp(() {
      verifyOtp = _MockVerifyOtp();
      requestOtp = _MockRequestOtp();
      clock = FakeClock(DateTime(2026, 11, 10, 12));
      ticker = FakeIntervalTicker();
    });

    tearDown(() async => ticker.dispose());

    OtpVerificationBloc build() => OtpVerificationBloc(
      verifyOtp: verifyOtp,
      requestOtp: requestOtp,
      clock: clock,
      ticker: ticker,
    );

    void stubVerify(Result<OtpVerification> result) => when(
      () => verifyOtp(
        phoneE164: any(named: 'phoneE164'),
        code: any(named: 'code'),
      ),
    ).thenAnswer((_) async => result);

    blocTest<OtpVerificationBloc, OtpVerificationState>(
      'verifies a correct code for a new number',
      setUp: () => stubVerify(const Ok(OtpVerification(isRegistered: false))),
      build: build,
      act: (bloc) => bloc
        ..add(const OtpVerificationStarted(phoneE164: _phone))
        ..add(const OtpCodeChanged('123456')),
      expect: () => [
        isA<OtpVerificationState>()
            .having((s) => s.code, 'code', '')
            .having(
              (s) => s.remaining,
              'remaining',
              const Duration(minutes: 5),
            ),
        isA<OtpVerificationState>().having((s) => s.code, 'code', '123456'),
        isA<OtpVerificationState>().having(
          (s) => s.verifying,
          'verifying',
          true,
        ),
        isA<OtpVerificationState>().having(
          (s) => s.verifiedIsRegistered,
          'verified',
          false,
        ),
      ],
    );

    blocTest<OtpVerificationBloc, OtpVerificationState>(
      'rejects a wrong code and clears the digits',
      setUp: () => stubVerify(const Err(_wrongCode)),
      build: build,
      act: (bloc) => bloc
        ..add(const OtpVerificationStarted(phoneE164: _phone))
        ..add(const OtpCodeChanged('000000')),
      expect: () => [
        isA<OtpVerificationState>(),
        isA<OtpVerificationState>().having((s) => s.code, 'code', '000000'),
        isA<OtpVerificationState>().having(
          (s) => s.verifying,
          'verifying',
          true,
        ),
        isA<OtpVerificationState>()
            .having((s) => s.code, 'code', '')
            .having((s) => s.failedAttempts, 'attempts', 1)
            .having((s) => s.failure, 'failure', _wrongCode)
            .having((s) => s.shakeEpoch, 'shake', 1),
      ],
    );

    blocTest<OtpVerificationBloc, OtpVerificationState>(
      'locks after three wrong codes',
      setUp: () => stubVerify(const Err(_wrongCode)),
      build: build,
      act: (bloc) async {
        bloc.add(const OtpVerificationStarted(phoneE164: _phone));
        for (final code in ['000000', '111111', '222222']) {
          bloc.add(OtpCodeChanged(code));
          await Future<void>.delayed(Duration.zero);
        }
      },
      verify: (bloc) {
        expect(bloc.state.locked, isTrue);
        expect(bloc.state.failedAttempts, 3);
      },
    );

    blocTest<OtpVerificationBloc, OtpVerificationState>(
      'resend unlocks and restarts the countdown',
      setUp: () {
        stubVerify(const Err(_wrongCode));
        when(() => requestOtp(_phone)).thenAnswer(
          (_) async => const Ok(Unit.value),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const OtpVerificationStarted(phoneE164: _phone));
        for (final code in ['000000', '111111', '222222']) {
          bloc.add(OtpCodeChanged(code));
          await Future<void>.delayed(Duration.zero);
        }
        clock.advance(const Duration(minutes: 5));
        ticker.emit();
        await Future<void>.delayed(Duration.zero);
        bloc.add(const OtpResendRequested());
        await Future<void>.delayed(Duration.zero);
      },
      verify: (bloc) {
        expect(bloc.state.locked, isFalse);
        expect(bloc.state.failedAttempts, 0);
        expect(bloc.state.remaining, const Duration(minutes: 5));
        verify(() => requestOtp(_phone)).called(1);
      },
    );

    blocTest<OtpVerificationBloc, OtpVerificationState>(
      'countdown reaches zero and enables resend',
      build: build,
      act: (bloc) async {
        bloc.add(const OtpVerificationStarted(phoneE164: _phone));
        await Future<void>.delayed(Duration.zero);
        clock.advance(const Duration(seconds: 2));
        ticker.emit();
        await Future<void>.delayed(Duration.zero);
        clock.advance(const Duration(minutes: 4, seconds: 58));
        ticker.emit();
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<OtpVerificationState>().having(
          (s) => s.remaining,
          'remaining',
          const Duration(minutes: 5),
        ),
        isA<OtpVerificationState>().having(
          (s) => s.remaining,
          'remaining',
          const Duration(minutes: 4, seconds: 58),
        ),
        isA<OtpVerificationState>()
            .having((s) => s.remaining, 'remaining', Duration.zero)
            .having((s) => s.canResend, 'canResend', true),
      ],
    );

    blocTest<OtpVerificationBloc, OtpVerificationState>(
      'ignores a second submit while verifying',
      build: build,
      act: (bloc) async {
        final pending = Completer<Result<OtpVerification>>();
        when(
          () => verifyOtp(
            phoneE164: any(named: 'phoneE164'),
            code: any(named: 'code'),
          ),
        ).thenAnswer((_) => pending.future);
        bloc
          ..add(const OtpVerificationStarted(phoneE164: _phone))
          ..add(const OtpCodeChanged('123456'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const OtpCodeChanged('123456'));
        await Future<void>.delayed(Duration.zero);
        pending.complete(const Ok(OtpVerification(isRegistered: false)));
      },
      verify: (_) => verify(
        () => verifyOtp(phoneE164: _phone, code: '123456'),
      ).called(1),
    );

    blocTest<OtpVerificationBloc, OtpVerificationState>(
      'computes remaining from the end timestamp after backgrounding',
      build: build,
      act: (bloc) async {
        bloc.add(const OtpVerificationStarted(phoneE164: _phone));
        await Future<void>.delayed(Duration.zero);
        clock.advance(const Duration(minutes: 3));
        ticker.emit();
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<OtpVerificationState>().having(
          (s) => s.remaining,
          'remaining',
          const Duration(minutes: 5),
        ),
        isA<OtpVerificationState>().having(
          (s) => s.remaining,
          'remaining',
          const Duration(minutes: 2),
        ),
      ],
    );
  });

  group('RegistrationBloc name step', () {
    late _MockSaveRegistrationName saveName;
    late _MockRegisterUser registerUser;
    late Completer<Result<Unit>> pending;

    setUp(() {
      saveName = _MockSaveRegistrationName();
      registerUser = _MockRegisterUser();
      pending = Completer();
    });

    RegistrationBloc build() => RegistrationBloc(
      saveRegistrationName: saveName,
      registerUser: registerUser,
      clock: FakeClock(DateTime(2026, 11, 10)),
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'keeps Continue disabled for invalid input and hides errors until blur',
      build: build,
      act: (bloc) => bloc
        ..add(const RegistrationFirstNameChanged('Ye1'))
        ..add(const RegistrationFirstNameFocusChanged(focused: false)),
      expect: () => [
        isA<RegistrationState>()
            .having((s) => s.firstName, 'first', 'Ye1')
            .having((s) => s.canContinueName, 'continue', false)
            .having((s) => s.firstNameErrorCode, 'error', isNull),
        isA<RegistrationState>().having(
          (s) => s.firstNameErrorCode,
          'error',
          AuthValidators.firstNameInvalidCode,
        ),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'enables Continue for valid names and advances after save',
      setUp: () => when(
        () => saveName(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
        ),
      ).thenAnswer((_) async => const Ok(Unit.value)),
      build: build,
      act: (bloc) => bloc
        ..add(const RegistrationFirstNameChanged('Ye Min'))
        ..add(const RegistrationLastNameChanged('Phyoe Win'))
        ..add(const RegistrationNameSubmitted()),
      expect: () => [
        isA<RegistrationState>().having((s) => s.firstName, 'first', 'Ye Min'),
        isA<RegistrationState>()
            .having((s) => s.lastName, 'last', 'Phyoe Win')
            .having((s) => s.canContinueName, 'continue', true),
        isA<RegistrationState>().having(
          (s) => s.firstNameTouched && s.lastNameTouched,
          'touched',
          true,
        ),
        isA<RegistrationState>().having((s) => s.nameSubmitting, 'busy', true),
        isA<RegistrationState>()
            .having((s) => s.nameSubmitting, 'busy', false)
            .having((s) => s.nameAdvanceToken, 'token', 1)
            .having((s) => s.firstName, 'first', 'Ye Min'),
      ],
      verify: (_) => verify(
        () => saveName(firstName: 'Ye Min', lastName: 'Phyoe Win'),
      ).called(1),
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'ignores a second name submit while one is running',
      setUp: () => when(
        () => saveName(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
        ),
      ).thenAnswer((_) => pending.future),
      build: build,
      act: (bloc) async {
        bloc
          ..add(const RegistrationFirstNameChanged('Su'))
          ..add(const RegistrationNameSubmitted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const RegistrationNameSubmitted());
        await Future<void>.delayed(Duration.zero);
        pending.complete(const Ok(Unit.value));
      },
      verify: (_) => verify(
        () => saveName(firstName: 'Su', lastName: ''),
      ).called(1),
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'keeps draft names after the step has already advanced once',
      build: build,
      seed: () => const RegistrationState(
        firstName: 'Ye Min',
        lastName: 'Phyoe Win',
        nameAdvanceToken: 1,
      ),
      verify: (bloc) {
        expect(bloc.state.firstName, 'Ye Min');
        expect(bloc.state.lastName, 'Phyoe Win');
        expect(bloc.state.nameAdvanceToken, 1);
        expect(bloc.state.canContinueName, isTrue);
      },
    );
  });

  group('RegistrationBloc date of birth step', () {
    late _MockSaveRegistrationName saveName;
    late _MockRegisterUser registerUser;
    late FakeClock clock;
    late Completer<Result<UserProfile>> pending;
    final today = DateTime(2026, 11, 10);

    setUp(() {
      saveName = _MockSaveRegistrationName();
      registerUser = _MockRegisterUser();
      clock = FakeClock(today);
      pending = Completer();
      registerFallbackValue(
        RegistrationDetails(firstName: 'Su', dateOfBirth: DateTime(2000)),
      );
    });

    RegistrationBloc build() => RegistrationBloc(
      saveRegistrationName: saveName,
      registerUser: registerUser,
      clock: clock,
    );

    RegistrationState namedDraft({
      int? month,
      String dayText = '',
      String yearText = '',
    }) => RegistrationState(
      firstName: 'Ye Min',
      lastName: 'Phyoe Win',
      month: month,
      dayText: dayText,
      yearText: yearText,
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'selects a month and types day and year',
      build: build,
      seed: namedDraft,
      act: (bloc) => bloc
        ..add(const RegistrationMonthSelected(5))
        ..add(const RegistrationDayChanged('1'))
        ..add(const RegistrationYearChanged('2000')),
      expect: () => [
        isA<RegistrationState>()
            .having((s) => s.month, 'month', 5)
            .having((s) => s.dayFocusToken, 'focus', 1),
        isA<RegistrationState>().having((s) => s.dayText, 'day', '1'),
        isA<RegistrationState>()
            .having((s) => s.yearText, 'year', '2000')
            .having((s) => s.canSubmit(today), 'submit', true),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'reveals an error after blur of an invalid date',
      build: build,
      seed: () => namedDraft(month: 4, dayText: '31', yearText: '2001'),
      act: (bloc) =>
          bloc.add(const RegistrationDayFocusChanged(focused: false)),
      expect: () => [
        isA<RegistrationState>()
            .having((s) => s.dayTouched, 'touched', true)
            .having(
              (s) => s.dobErrorCode(today),
              'error',
              AuthValidators.dobNotRealCode,
            )
            .having((s) => s.canSubmit(today), 'submit', false),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'enables Continue only for a valid date and loads on submit',
      setUp: () => when(() => registerUser(any())).thenAnswer(
        (_) async => Ok(
          UserProfile(
            id: 'u_1',
            phoneE164: _phone,
            firstName: 'Ye Min',
            dateOfBirth: DateTime(2000, 5),
          ),
        ),
      ),
      build: build,
      seed: () => namedDraft(month: 5, dayText: '1', yearText: '2000'),
      act: (bloc) => bloc.add(const RegistrationSubmitted()),
      expect: () => [
        isA<RegistrationState>().having(
          (s) => s.monthTouched && s.dayTouched && s.yearTouched,
          'touched',
          true,
        ),
        isA<RegistrationState>().having(
          (s) => s.status,
          'status',
          RegistrationStatus.submitting,
        ),
        isA<RegistrationState>().having(
          (s) => s.status,
          'status',
          RegistrationStatus.completed,
        ),
      ],
      verify: (_) => verify(() => registerUser(any())).called(1),
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'ignores a second submit while one is running',
      setUp: () =>
          when(() => registerUser(any())).thenAnswer((_) => pending.future),
      build: build,
      seed: () => namedDraft(month: 5, dayText: '1', yearText: '2000'),
      act: (bloc) async {
        bloc.add(const RegistrationSubmitted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const RegistrationSubmitted());
        await Future<void>.delayed(Duration.zero);
        pending.complete(
          Ok(
            UserProfile(
              id: 'u_1',
              phoneE164: _phone,
              firstName: 'Ye Min',
              dateOfBirth: DateTime(2000, 5),
            ),
          ),
        );
      },
      verify: (_) => verify(() => registerUser(any())).called(1),
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'reports a failure from register',
      setUp: () => when(
        () => registerUser(any()),
      ).thenAnswer((_) async => const Err(NetworkFailure())),
      build: build,
      seed: () => namedDraft(month: 5, dayText: '1', yearText: '2000'),
      act: (bloc) => bloc.add(const RegistrationSubmitted()),
      expect: () => [
        isA<RegistrationState>(),
        isA<RegistrationState>().having(
          (s) => s.status,
          'status',
          RegistrationStatus.submitting,
        ),
        isA<RegistrationState>()
            .having((s) => s.status, 'status', RegistrationStatus.failed)
            .having((s) => s.failure, 'failure', const NetworkFailure()),
      ],
    );

    blocTest<RegistrationBloc, RegistrationState>(
      'restores the date draft after returning',
      build: build,
      seed: () => namedDraft(month: 5, dayText: '1', yearText: '1980'),
      verify: (bloc) {
        expect(bloc.state.month, 5);
        expect(bloc.state.dayText, '1');
        expect(bloc.state.yearText, '1980');
        expect(bloc.state.canSubmit(today), isTrue);
      },
    );
  });
}
