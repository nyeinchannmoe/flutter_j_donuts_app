import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/entities/session.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';

class RestoreSession {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  Future<Result<Session>> call() => _repository.restoreSession();
}
