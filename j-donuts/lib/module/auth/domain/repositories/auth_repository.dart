import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/entities/otp_verification.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/entities/session.dart';
import 'package:jdonuts/module/auth/domain/entities/user_profile.dart';

/// Authentication contract. The fake implementation can be replaced by a
/// real API without touching presentation code.
abstract interface class AuthRepository {
  /// Emits the current session immediately, then every change.
  Stream<Session> watchSession();

  /// Reads the persisted session. Never fails into an unusable state:
  /// unreadable storage resolves to unauthenticated.
  Future<Result<Session>> restoreSession();

  Future<Result<Unit>> requestOtp(String phoneE164);

  Future<Result<OtpVerification>> verifyOtp({
    required String phoneE164,
    required String code,
    bool existingAccountOnly = false,
  });

  /// Completes registration for the phone number verified last.
  Future<Result<UserProfile>> register(RegistrationDetails details);

  Future<Result<Unit>> signOut();
}
