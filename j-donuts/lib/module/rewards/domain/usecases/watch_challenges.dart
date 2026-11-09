import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/domain/repositories/rewards_repository.dart';

class WatchChallenges {
  const WatchChallenges(this._repository);

  final RewardsRepository _repository;

  Stream<Result<List<Challenge>>> call() => _repository.watchChallenges();
}
