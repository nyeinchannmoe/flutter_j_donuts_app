import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/entities/user_profile.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

class RegisterUser {
  const RegisterUser(this._repository, {this._today = _now});

  static const String invalidDetailsCode = 'auth.invalidRegistration';

  final AuthRepository _repository;
  final DateTime Function() _today;

  static DateTime _now() => DateTime.now();

  Future<Result<UserProfile>> call(RegistrationDetails details) async {
    final firstOk = AuthValidators.validateFirstName(details.firstName) is Ok;
    final lastOk =
        AuthValidators.validateLastName(details.lastName ?? '') is Ok;
    final dobOk = AuthValidators.isDateOfBirthValid(
      details.dateOfBirth,
      _today(),
    );
    if (!firstOk || !lastOk || !dobOk) {
      return const Err(ValidationFailure(code: invalidDetailsCode));
    }
    return _repository.register(details);
  }
}
