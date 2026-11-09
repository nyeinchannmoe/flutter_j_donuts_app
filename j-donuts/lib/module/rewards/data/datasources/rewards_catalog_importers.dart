import 'package:jdonuts/core/database/daos/challenges_dao.dart';
import 'package:jdonuts/core/database/daos/member_dao.dart';
import 'package:jdonuts/core/database/seed/catalog_importer.dart';
import 'package:jdonuts/module/rewards/data/mappers/rewards_mappers.dart';
import 'package:jdonuts/module/rewards/data/models/challenge_dto.dart';
import 'package:jdonuts/module/rewards/data/models/tier_dto.dart';

List<Map<String, Object?>> _objects(Object? json) =>
    (json! as List<Object?>).cast<Map<String, Object?>>();

/// Tiers are referenced by the member record, so they import first.
class TiersCatalogImporter implements CatalogImporter {
  const TiersCatalogImporter(this._dao);

  final MemberDao _dao;

  @override
  String get sectionKey => 'tiers';

  @override
  ImportStage get stage => ImportStage.reference;

  @override
  bool get acceptsRemoteUpdates => true;

  @override
  Future<void> importSection(Object? json) => _dao.upsertTiers([
    for (final tier in _objects(json)) TierDto.fromJson(tier).toCompanion(),
  ]);
}

class ChallengesCatalogImporter implements CatalogImporter {
  const ChallengesCatalogImporter(this._dao);

  final ChallengesDao _dao;

  @override
  String get sectionKey => 'challenges';

  @override
  ImportStage get stage => ImportStage.reference;

  @override
  bool get acceptsRemoteUpdates => true;

  @override
  Future<void> importSection(Object? json) => _dao.upsertChallenges([
    for (final challenge in _objects(json))
      ChallengeDto.fromJson(challenge).toCompanion(),
  ]);
}
