import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

class SaveRegistrationName {
  const SaveRegistrationName(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call({
    required String firstName,
    required String lastName,
  }) async {
    final first = AuthValidators.validateFirstName(firstName);
    final firstValue = first.valueOrNull;
    if (firstValue == null) return Err(first.failureOrNull!);
    final last = AuthValidators.validateLastName(lastName);
    final lastValue = last.valueOrNull;
    if (lastValue == null) return Err(last.failureOrNull!);
    return _repository.saveRegistrationName(
      firstName: firstValue,
      lastName: lastValue.isEmpty ? null : lastValue,
    );
  }
}
