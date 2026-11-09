import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/rewards/domain/entities/tier.dart';
import 'package:jdonuts/module/rewards/domain/repositories/rewards_repository.dart';

class WatchTiers {
  const WatchTiers(this._repository);

  final RewardsRepository _repository;

  Stream<Result<List<Tier>>> call() => _repository.watchTiers();
}
