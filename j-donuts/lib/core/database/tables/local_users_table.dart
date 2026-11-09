import 'package:drift/drift.dart';

/// Users registered on this device by the fake auth repository.
@DataClassName('LocalUserRow')
class LocalUsers extends Table {
  TextColumn get id => text()();
  TextColumn get phoneE164 => text().unique()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
