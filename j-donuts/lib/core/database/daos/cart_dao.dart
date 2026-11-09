import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/tables/cart_items_table.dart';

part 'cart_dao.g.dart';

@DriftAccessor(tables: [CartItems])
class CartDao extends DatabaseAccessor<AppDatabase> with _$CartDaoMixin {
  CartDao(super.attachedDatabase);

  /// Adds [quantity] to the line for [productId] in one transaction and
  /// returns the new line quantity.
  Future<int> addQuantity({
    required String productId,
    required int quantity,
    required DateTime now,
  }) => transaction(() async {
    final current = await (select(
      cartItems,
    )..where((row) => row.productId.equals(productId))).getSingleOrNull();
    final updated = (current?.quantity ?? 0) + quantity;
    await into(cartItems).insertOnConflictUpdate(
      CartItemsCompanion.insert(
        productId: productId,
        quantity: updated,
        updatedAt: now,
      ),
    );
    return updated;
  });
}
