import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/domain/repositories/home_repository.dart';

class WatchHomeSection {
  const WatchHomeSection(this._repository);

  final HomeRepository _repository;

  Stream<Result<HomeSection?>> call(HomeSectionKind kind) =>
      _repository.watchSection(kind);
}
