import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/product/domain/entities/cart_rules.dart';
import 'package:jdonuts/module/product/domain/repositories/cart_repository.dart';

class AddToCart {
  const AddToCart(this._repository);

  static const String quantityOutOfRangeCode = 'cart.quantityOutOfRange';

  final CartRepository _repository;

  Future<Result<int>> call({
    required String productId,
    required int quantity,
  }) async {
    if (quantity < CartRules.minQuantity || quantity > CartRules.maxQuantity) {
      return const Err(ValidationFailure(code: quantityOutOfRangeCode));
    }
    return _repository.addToCart(productId: productId, quantity: quantity);
  }
}
