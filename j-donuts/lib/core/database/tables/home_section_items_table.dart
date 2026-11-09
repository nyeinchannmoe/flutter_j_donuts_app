import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/tables/home_sections_table.dart';
import 'package:jdonuts/core/database/tables/products_table.dart';

@DataClassName('HomeSectionItemRow')
@TableIndex(
  name: 'home_section_items_order_idx',
  columns: {#sectionId, #sortOrder},
)
class HomeSectionItems extends Table {
  TextColumn get sectionId =>
      text().references(HomeSections, #id, onDelete: KeyAction.cascade)();
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortOrder => integer()();
  IntColumn get discountPercent => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {sectionId, productId};
}
