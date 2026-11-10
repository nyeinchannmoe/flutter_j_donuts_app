import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';

/// Whether the given E.164 phone already belongs to a stored member.
class CheckPhoneRegistered {
  const CheckPhoneRegistered(this._repository);

  final AuthRepository _repository;

  Future<Result<bool>> call(String phoneE164) =>
      _repository.isPhoneRegistered(phoneE164);
}
