import 'package:jdonuts/core/result/result.dart';

abstract interface class CartRepository {
  /// Adds [quantity] of [productId] and returns the new line quantity.
  Future<Result<int>> addToCart({
    required String productId,
    required int quantity,
  });
}
