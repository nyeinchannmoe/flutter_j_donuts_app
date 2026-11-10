import 'package:jdonuts/core/database/daos/member_dao.dart';
import 'package:jdonuts/core/database/seed/catalog_importer.dart';
import 'package:jdonuts/core/member/data/mappers/member_mapper.dart';
import 'package:jdonuts/core/member/data/models/member_dto.dart';

/// Seeds the member record (points, photo, tier). Display name starts empty
/// and is written by registration. Remote refreshes never overwrite it
/// because the member's points and counters are owned by the device session.
class MemberCatalogImporter implements CatalogImporter {
  const MemberCatalogImporter(this._dao);

  final MemberDao _dao;

  @override
  String get sectionKey => 'member';

  @override
  ImportStage get stage => ImportStage.dependent;

  @override
  bool get acceptsRemoteUpdates => false;

  @override
  Future<void> importSection(Object? json) => _dao.upsertMember(
    MemberDto.fromJson(json! as Map<String, Object?>).toCompanion(),
  );
}
