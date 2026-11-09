import 'package:jdonuts/core/database/daos/challenges_dao.dart';
import 'package:jdonuts/core/database/daos/member_dao.dart';
import 'package:jdonuts/core/error/guard.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/rewards/data/mappers/rewards_mappers.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/domain/entities/tier.dart';
import 'package:jdonuts/module/rewards/domain/repositories/rewards_repository.dart';

class RewardsRepositoryImpl implements RewardsRepository {
  const RewardsRepositoryImpl({
    required this._memberDao,
    required this._challengesDao,
    required this._logger,
  });

  final MemberDao _memberDao;
  final ChallengesDao _challengesDao;
  final AppLogger _logger;

  @override
  Stream<Result<List<Tier>>> watchTiers() => guardStream(
    _memberDao.watchTiers().map(
      (rows) => [for (final row in rows) row.toEntity()],
    ),
    logger: _logger,
  );

  @override
  Stream<Result<List<Challenge>>> watchChallenges() => guardStream(
    _challengesDao.watchChallenges().map(
      (rows) => [for (final row in rows) row.toEntity()],
    ),
    logger: _logger,
  );
}
