import 'package:drift/drift.dart';

/// Key-value store for app metadata: seed version, sync timestamps, locale.
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
