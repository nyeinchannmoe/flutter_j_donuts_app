import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/home/domain/entities/shop.dart';
import 'package:jdonuts/module/home/domain/repositories/home_repository.dart';

class WatchShops {
  const WatchShops(this._repository);

  final HomeRepository _repository;

  Stream<Result<List<Shop>>> call() => _repository.watchShops();
}
