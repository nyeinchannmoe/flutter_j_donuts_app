import 'dart:async';

import 'package:jdonuts/core/database/daos/local_users_dao.dart';
import 'package:jdonuts/core/error/app_exception.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/error/guard.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/storage/session_store.dart';
import 'package:jdonuts/core/storage/stored_session.dart';
import 'package:jdonuts/core/utils/clock.dart';
import 'package:jdonuts/module/auth/data/datasources/fake_otp_gateway.dart';
import 'package:jdonuts/module/auth/data/mappers/local_user_mapper.dart';
import 'package:jdonuts/module/auth/domain/entities/otp_verification.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/entities/session.dart';
import 'package:jdonuts/module/auth/domain/entities/user_profile.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';

/// Local-only auth: users live in the local_users table, the OTP is the
/// demo code and the session is kept in secure storage.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required this._usersDao,
    required this._sessionStore,
    required this._otpGateway,
    required this._logger,
    this._clock = const SystemClock(),
  });

  static const String noPendingVerificationCode = 'auth.noPendingVerification';
  static const String _userIdPrefix = 'u_';

  final LocalUsersDao _usersDao;
  final SessionStore _sessionStore;
  final FakeOtpGateway _otpGateway;
  final AppLogger _logger;
  final Clock _clock;
  final StreamController<Session> _changes =
      StreamController<Session>.broadcast();
  Session _current = const Session.unknown();

  @override
  Stream<Session> watchSession() async* {
    yield _current;
    yield* _changes.stream;
  }

  @override
  Future<Result<Session>> restoreSession() async {
    final restored = await _guard(_readStoredSession);
    return Ok(
      _publish(restored.valueOrNull ?? const Session.unauthenticated()),
    );
  }

  Future<Session> _readStoredSession() async {
    final stored = await _sessionStore.read();
    if (stored == null) return const Session.unauthenticated();
    final user = await _usersDao.findById(stored.userId);
    if (user == null) {
      await _sessionStore.clear();
      return const Session.unauthenticated();
    }
    return Session.authenticated(userId: user.id, phoneE164: user.phoneE164);
  }

  @override
  Future<Result<Unit>> requestOtp(String phoneE164) => _guard(() async {
    await _otpGateway.sendCode(phoneE164);
    return Unit.value;
  });

  @override
  Future<Result<OtpVerification>> verifyOtp({
    required String phoneE164,
    required String code,
    bool existingAccountOnly = false,
  }) async {
    final accepted = await _guard(() => _otpGateway.verifyCode(code));
    return switch (accepted) {
      Err(:final failure) => Err(failure),
      Ok(value: false) => const Err(
        AuthFailure(code: FailureCodes.invalidCode),
      ),
      Ok() => _guard(
        () => _completeVerification(
          phoneE164,
          existingAccountOnly: existingAccountOnly,
        ),
      ),
    };
  }

  Future<OtpVerification> _completeVerification(
    String phoneE164, {
    required bool existingAccountOnly,
  }) async {
    final user = await _usersDao.findByPhone(phoneE164);
    if (user == null) {
      if (existingAccountOnly) {
        throw const AppException(
          AuthFailure(code: FailureCodes.accountMissing),
        );
      }
      _publish(Session.registering(phoneE164: phoneE164));
      return const OtpVerification(isRegistered: false);
    }
    await _startSession(user.id, phoneE164, isNewlyRegistered: false);
    return const OtpVerification(isRegistered: true);
  }

  @override
  Future<Result<Unit>> saveRegistrationName({
    required String firstName,
    String? lastName,
  }) => _guard(() async {
    await _otpGateway.simulateNetwork();
    return Unit.value;
  });

  @override
  Future<Result<UserProfile>> register(RegistrationDetails details) async {
    final pending = _current;
    if (pending is! SessionRegistering) {
      return const Err(AuthFailure(code: noPendingVerificationCode));
    }
    return _guard(() => _createUser(details, pending.phoneE164));
  }

  Future<UserProfile> _createUser(
    RegistrationDetails details,
    String phoneE164,
  ) async {
    await _otpGateway.simulateNetwork();
    final now = _clock.now();
    final id = '$_userIdPrefix${now.microsecondsSinceEpoch}';
    await _usersDao.insertUser(
      details.toCompanion(id: id, phoneE164: phoneE164, createdAt: now),
    );
    await _startSession(id, phoneE164, isNewlyRegistered: true);
    return (await _usersDao.findById(id))!.toEntity();
  }

  @override
  Future<Result<Unit>> signOut() => _guard(() async {
    await _sessionStore.clear();
    _publish(const Session.unauthenticated());
    return Unit.value;
  });

  Future<void> _startSession(
    String userId,
    String phoneE164, {
    required bool isNewlyRegistered,
  }) async {
    await _sessionStore.write(
      StoredSession(userId: userId, phoneE164: phoneE164),
    );
    _publish(
      Session.authenticated(
        userId: userId,
        phoneE164: phoneE164,
        isNewlyRegistered: isNewlyRegistered,
      ),
    );
  }

  Session _publish(Session session) {
    _current = session;
    _changes.add(session);
    return session;
  }

  Future<Result<T>> _guard<T>(Future<T> Function() body) =>
      guardResult(body, logger: _logger);
}
