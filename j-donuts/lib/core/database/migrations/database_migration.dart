import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/error/app_exception.dart';
import 'package:jdonuts/core/error/app_failure.dart';

/// Codes for failures raised while opening the database.
abstract final class DatabaseFailureCodes {
  static const String integrity = 'storage.integrity';
  static const String unsupportedUpgrade = 'storage.unsupportedUpgrade';
}

const String _integrityOk = 'ok';

/// Migration strategy for AppDatabase.
///
/// Upgrades run one schema version at a time. Each future version adds a
/// step built from the generated schema_versions.dart helpers; see
/// docs/DATABASE.md for the procedure.
MigrationStrategy buildMigrationStrategy(AppDatabase database) =>
    MigrationStrategy(
      onCreate: (migrator) => migrator.createAll(),
      onUpgrade: (migrator, from, to) => _upgrade(database, migrator, from, to),
      beforeOpen: (details) => _prepareConnection(database),
    );

Future<void> _upgrade(
  AppDatabase database,
  Migrator migrator,
  int from,
  int to,
) async {
  await database.customStatement('PRAGMA foreign_keys = OFF');
  await database.transaction(() async {
    for (var version = from; version < to; version++) {
      await _runStep(database, migrator, version);
    }
  });
}

Future<void> _runStep(
  AppDatabase database,
  Migrator migrator,
  int fromVersion,
) => switch (fromVersion) {
  1 => migrator.addColumn(database.banners, database.banners.cardTone),
  2 => migrator.addColumn(database.products, database.products.subtitle),
  _ => throw AppException(
    StorageFailure(
      code: DatabaseFailureCodes.unsupportedUpgrade,
      cause: 'No migration step from schema version $fromVersion',
    ),
  ),
};

Future<void> _prepareConnection(GeneratedDatabase database) async {
  await database.customStatement('PRAGMA foreign_keys = ON');
  final rows = await database.customSelect('PRAGMA quick_check').get();
  final verdict = rows.isEmpty ? null : rows.first.data.values.first;
  if (verdict != _integrityOk) {
    throw AppException(
      StorageFailure(
        code: DatabaseFailureCodes.integrity,
        cause: 'quick_check returned $verdict',
      ),
    );
  }
}
