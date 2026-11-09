/// Quantity limits for a single cart line.
abstract final class CartRules {
  static const int minQuantity = 1;
  static const int maxQuantity = 99;

  static int lineTotal({required int unitPriceMmk, required int quantity}) =>
      unitPriceMmk * quantity;
}
