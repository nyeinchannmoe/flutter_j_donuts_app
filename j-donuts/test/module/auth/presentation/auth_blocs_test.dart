import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/entities/otp_verification.dart';
import 'package:jdonuts/module/auth/domain/usecases/request_otp.dart';
import 'package:jdonuts/module/auth/domain/usecases/verify_otp.dart';
import 'package:jdonuts/module/auth/presentation/bloc/otp_verification/otp_verification_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/phone_entry/phone_entry_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockRequestOtp extends Mock implements RequestOtp {}

class _MockVerifyOtp extends Mock implements VerifyOtp {}

const String _phone = '+959123456789';
const AuthFailure _wrongCode = AuthFailure();

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
      act: (bloc) => bloc.add(const PhoneEntrySubmitted(_phone)),
      expect: () => const [
        PhoneEntryState.submitting(),
        PhoneEntryState.codeSent(phoneE164: _phone),
      ],
    );

    blocTest<PhoneEntryBloc, PhoneEntryState>(
      'reports a failure when the code cannot be sent',
      setUp: () => when(
        () => requestOtp(_phone),
      ).thenAnswer((_) async => const Err(NetworkFailure())),
      build: build,
      act: (bloc) => bloc.add(const PhoneEntrySubmitted(_phone)),
      expect: () => const [
        PhoneEntryState.submitting(),
        PhoneEntryState.failure(NetworkFailure()),
      ],
    );

    blocTest<PhoneEntryBloc, PhoneEntryState>(
      'ignores repeated submits while one is running',
      setUp: () => when(
        () => requestOtp(_phone),
      ).thenAnswer((_) => pending.future),
      build: build,
      act: (bloc) async {
        bloc.add(const PhoneEntrySubmitted(_phone));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const PhoneEntrySubmitted(_phone));
        await Future<void>.delayed(Duration.zero);
        pending.complete(const Ok(Unit.value));
      },
      verify: (_) => verify(() => requestOtp(_phone)).called(1),
    );
  });

  group('OtpVerificationBloc', () {
    late _MockVerifyOtp verifyOtp;

    setUp(() => verifyOtp = _MockVerifyOtp());

    OtpVerificationBloc build() => OtpVerificationBloc(verifyOtp: verifyOtp);

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
      act: (bloc) =>
          bloc.add(const OtpCodeSubmitted(phoneE164: _phone, code: '123456')),
      expect: () => const [
        OtpVerificationState.verifying(),
        OtpVerificationState.verified(isRegistered: false),
      ],
    );

    blocTest<OtpVerificationBloc, OtpVerificationState>(
      'counts consecutive wrong codes',
      setUp: () => stubVerify(const Err(_wrongCode)),
      build: build,
      act: (bloc) async {
        bloc.add(const OtpCodeSubmitted(phoneE164: _phone, code: '000000'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const OtpCodeSubmitted(phoneE164: _phone, code: '111111'));
      },
      expect: () => const [
        OtpVerificationState.verifying(),
        OtpVerificationState.rejected(failure: _wrongCode, failedAttempts: 1),
        OtpVerificationState.verifying(),
        OtpVerificationState.rejected(failure: _wrongCode, failedAttempts: 2),
      ],
    );
  });
}
