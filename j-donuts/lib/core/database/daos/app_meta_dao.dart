import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/tables/app_meta_table.dart';

part 'app_meta_dao.g.dart';

/// Keys stored in the app_meta table.
abstract final class AppMetaKeys {
  static const String seedVersion = 'seed_version';
  static const String locale = 'locale';
  static const String lastSyncPrefix = 'last_sync_at.';

  static String lastSyncAt(String scope) => '$lastSyncPrefix$scope';
}

@DriftAccessor(tables: [AppMeta])
class AppMetaDao extends DatabaseAccessor<AppDatabase> with _$AppMetaDaoMixin {
  AppMetaDao(super.attachedDatabase);

  Future<String?> readValue(String key) async {
    final query = select(appMeta)..where((row) => row.key.equals(key));
    final row = await query.getSingleOrNull();
    return row?.value;
  }

  Future<void> writeValue(String key, String value) => into(
    appMeta,
  ).insertOnConflictUpdate(AppMetaCompanion.insert(key: key, value: value));

  Future<void> deleteValue(String key) =>
      (delete(appMeta)..where((row) => row.key.equals(key))).go();
}
