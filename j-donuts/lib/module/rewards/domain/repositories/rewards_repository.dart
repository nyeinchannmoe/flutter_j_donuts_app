import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/domain/entities/tier.dart';

abstract interface class RewardsRepository {
  /// Tiers ordered from lowest to highest.
  Stream<Result<List<Tier>>> watchTiers();

  Stream<Result<List<Challenge>>> watchChallenges();
}
