import 'package:drift/drift.dart';

@DataClassName('ShopRow')
@TableIndex(name: 'shops_sort_order_idx', columns: {#sortOrder})
class Shops extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get address => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get imageAsset => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
