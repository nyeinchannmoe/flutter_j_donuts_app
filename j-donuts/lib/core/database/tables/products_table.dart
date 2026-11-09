import 'package:drift/drift.dart';

@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  IntColumn get priceMmk => integer()();
  BoolColumn get isNew => boolean()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get imageAsset => text()();
  TextColumn get description => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
