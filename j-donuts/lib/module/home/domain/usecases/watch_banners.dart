import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/home/domain/entities/home_banner.dart';
import 'package:jdonuts/module/home/domain/repositories/home_repository.dart';

class WatchBanners {
  const WatchBanners(this._repository);

  final HomeRepository _repository;

  Stream<Result<List<HomeBanner>>> call() => _repository.watchBanners();
}
