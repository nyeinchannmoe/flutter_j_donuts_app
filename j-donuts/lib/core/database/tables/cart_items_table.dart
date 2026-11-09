import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/tables/products_table.dart';

@DataClassName('CartItemRow')
class CartItems extends Table {
  TextColumn get productId =>
      text().references(Products, #id, onDelete: KeyAction.cascade)();
  // Drift CHECK constraints reference their own column getter.
  // ignore: recursive_getters
  IntColumn get quantity => integer().check(quantity.isBiggerThanValue(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {productId};
}
