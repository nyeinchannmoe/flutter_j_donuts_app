import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/tables/products_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.attachedDatabase);

  Future<ProductRow?> findById(String id) {
    final query = select(products)..where((row) => row.id.equals(id));
    return query.getSingleOrNull();
  }

  /// Upserts without deleting, so cart rows referencing a product survive.
  Future<void> upsertProducts(List<ProductsCompanion> rows) => batch(
    (batch) => batch.insertAllOnConflictUpdate(products, rows),
  );
}
