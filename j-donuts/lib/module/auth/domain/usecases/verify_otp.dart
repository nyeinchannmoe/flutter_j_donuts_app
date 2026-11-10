import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/entities/otp_verification.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

class VerifyOtp {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<OtpVerification>> call({
    required String phoneE164,
    required String code,
    bool existingAccountOnly = false,
  }) async {
    if (!AuthValidators.isOtpComplete(code)) {
      return const Err(ValidationFailure(code: FailureCodes.invalidCode));
    }
    return _repository.verifyOtp(
      phoneE164: phoneE164,
      code: code,
      existingAccountOnly: existingAccountOnly,
    );
  }
}
