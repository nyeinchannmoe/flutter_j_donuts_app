import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';

class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<Result<Unit>> call() => _repository.signOut();
}
