import 'package:drift/drift.dart';

/// Home product rails. [kind] is unique so each rail is addressable.
@DataClassName('HomeSectionRow')
class HomeSections extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text().unique()();
  TextColumn get title => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
