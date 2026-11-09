import 'package:drift/drift.dart';

@DataClassName('BannerRow')
@TableIndex(name: 'banners_sort_order_idx', columns: {#sortOrder})
class Banners extends Table {
  TextColumn get id => text()();
  TextColumn get tag => text().nullable()();
  TextColumn get title => text()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get imageAsset => text()();
  /// Named theme tone key for the colored promo shell (e.g. violet, sky).
  TextColumn get cardTone => text().nullable()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
