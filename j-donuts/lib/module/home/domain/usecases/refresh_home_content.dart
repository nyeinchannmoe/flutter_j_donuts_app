import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/home/domain/repositories/home_repository.dart';

class RefreshHomeContent {
  const RefreshHomeContent(this._repository);

  final HomeRepository _repository;

  Future<Result<Unit>> call() => _repository.refresh();
}
