import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/storage/session_store.dart';
import 'package:jdonuts/module/auth/data/datasources/fake_otp_gateway.dart';
import 'package:jdonuts/module/auth/data/repositories/fake_auth_repository.dart';
import 'package:jdonuts/module/auth/domain/entities/otp_verification.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/entities/session.dart';

import '../../../helpers/fake_clock.dart';
import '../../../helpers/test_database.dart';
import '../../../helpers/test_doubles.dart';

const String _phone = '+959123456789';

void main() {
  late AppDatabase database;
  late InMemoryKeyValueStore storage;

  FakeAuthRepository buildRepository() => FakeAuthRepository(
    usersDao: database.localUsersDao,
    sessionStore: SessionStore(store: storage, logger: silentLogger()),
    otpGateway: const FakeOtpGateway(latency: noLatency),
    logger: silentLogger(),
    clock: FakeClock(DateTime(2026, 11, 9)),
  );

  Future<void> registerNewMember(FakeAuthRepository repository) async {
    await repository.verifyOtp(
      phoneE164: _phone,
      code: FakeOtpGateway.demoCode,
    );
    await repository.register(
      RegistrationDetails(firstName: 'Su', dateOfBirth: DateTime(2000)),
    );
  }

  setUp(() {
    database = openTestDatabase();
    storage = InMemoryKeyValueStore();
  });
  tearDown(() => database.close());

  group('FakeAuthRepository', () {
    test('restores to unauthenticated when nothing is stored', () async {
      final result = await buildRepository().restoreSession();

      expect(result, const Ok<Session>(Session.unauthenticated()));
    });

    test('rejects a wrong code', () async {
      final result = await buildRepository().verifyOtp(
        phoneE164: _phone,
        code: '000000',
      );

      expect(result.failureOrNull?.code, FailureCodes.invalidCode);
    });

    test('an unknown phone moves the session to registering', () async {
      final repository = buildRepository();

      final result = await repository.verifyOtp(
        phoneE164: _phone,
        code: FakeOtpGateway.demoCode,
      );

      expect(result, const Ok(OtpVerification(isRegistered: false)));
      expect(
        await repository.watchSession().first,
        const Session.registering(phoneE164: _phone),
      );
    });

    test('registration signs in as a newly registered member', () async {
      final repository = buildRepository();

      await registerNewMember(repository);

      final session = await repository.watchSession().first;
      expect(session, isA<SessionAuthenticated>());
      expect((session as SessionAuthenticated).isNewlyRegistered, isTrue);
    });

    test('register without a verified phone fails', () async {
      final result = await buildRepository().register(
        RegistrationDetails(firstName: 'Su', dateOfBirth: DateTime(2000)),
      );

      expect(
        result.failureOrNull?.code,
        FakeAuthRepository.noPendingVerificationCode,
      );
    });

    test('a stored session survives a restart', () async {
      await registerNewMember(buildRepository());

      final restored = await buildRepository().restoreSession();

      final session = restored.valueOrNull;
      expect(session, isA<SessionAuthenticated>());
      expect((session! as SessionAuthenticated).isNewlyRegistered, isFalse);
    });

    test('a returning member is signed in directly after the code', () async {
      await registerNewMember(buildRepository());
      final repository = buildRepository();

      final result = await repository.verifyOtp(
        phoneE164: _phone,
        code: FakeOtpGateway.demoCode,
      );

      expect(result, const Ok(OtpVerification(isRegistered: true)));
    });

    test('sign out clears the stored session', () async {
      final repository = buildRepository();
      await registerNewMember(repository);

      await repository.signOut();

      expect(storage.values, isEmpty);
      expect(
        await buildRepository().restoreSession(),
        const Ok<Session>(Session.unauthenticated()),
      );
    });
  });
}
