import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/database/app_database.dart';

import 'generated/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('every exported schema version matches the current tables', () async {
    for (final version in GeneratedHelper.versions) {
      final connection = await verifier.startAt(version);
      final database = AppDatabase(connection);
      addTearDown(database.close);
      await verifier.migrateAndValidate(database, DatabaseSchema.version);
    }
  });

  test('the latest export is the current schema version', () {
    expect(GeneratedHelper.versions.last, DatabaseSchema.version);
  });

  test('a fresh database opens with foreign keys enforced', () async {
    final connection = await verifier.startAt(DatabaseSchema.version);
    final database = AppDatabase(connection);
    addTearDown(database.close);
    final rows = await database.customSelect('PRAGMA foreign_keys').get();
    expect(rows.single.data.values.single, 1);
  });
}
