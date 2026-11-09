import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/module/rewards/data/models/challenge_dto.dart';
import 'package:jdonuts/module/rewards/data/models/tier_dto.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/domain/entities/tier.dart';

extension TierDtoMapper on TierDto {
  TiersCompanion toCompanion() => TiersCompanion.insert(
    id: id,
    name: name,
    minPoints: minPoints,
    sortOrder: sortOrder,
  );
}

extension TierRowMapper on TierRow {
  Tier toEntity() =>
      Tier(id: id, name: name, minPoints: minPoints, rank: sortOrder);
}

extension ChallengeDtoMapper on ChallengeDto {
  /// Leaves `claimed` absent so reseeding never resets user progress.
  /// Throws ArgumentError for an unknown kind.
  ChallengesCompanion toCompanion() {
    ChallengeKind.values.byName(kind);
    return ChallengesCompanion.insert(
      id: id,
      title: title,
      kind: kind,
      progressCurrent: progressCurrent,
      progressTarget: progressTarget,
      rewardPoints: rewardPoints,
      imageAsset: imageAsset,
      sortOrder: sortOrder,
    );
  }
}

extension ChallengeRowMapper on ChallengeRow {
  Challenge toEntity() => Challenge(
    id: id,
    title: title,
    kind: ChallengeKind.values.byName(kind),
    progressCurrent: progressCurrent,
    progressTarget: progressTarget,
    rewardPoints: rewardPoints,
    imageAsset: imageAsset,
    claimed: claimed,
  );
}
