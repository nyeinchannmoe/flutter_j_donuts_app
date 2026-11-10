import 'package:drift/drift.dart';

@DataClassName('BannerRow')
@TableIndex(name: 'banners_sort_order_idx', columns: {#sortOrder})
class Banners extends Table {
  TextColumn get id => text()();
  TextColumn get tag => text().nullable()();
  TextColumn get title => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get imageAsset => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
