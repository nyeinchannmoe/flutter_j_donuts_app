import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

class RequestOtp {
  const RequestOtp(this._repository);

  static const String invalidPhoneCode = 'auth.invalidPhone';

  final AuthRepository _repository;

  /// [phoneE164] must already be a normalised Myanmar mobile number.
  Future<Result<Unit>> call(String phoneE164) async {
    if (AuthValidators.toMyanmarE164(phoneE164) != phoneE164) {
      return const Err(ValidationFailure(code: invalidPhoneCode));
    }
    return _repository.requestOtp(phoneE164);
  }
}
