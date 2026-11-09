import 'package:jdonuts/module/auth/domain/entities/session.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';

class WatchSession {
  const WatchSession(this._repository);

  final AuthRepository _repository;

  Stream<Session> call() => _repository.watchSession();
}
