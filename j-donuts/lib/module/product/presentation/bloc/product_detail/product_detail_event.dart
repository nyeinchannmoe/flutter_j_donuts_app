part of 'product_detail_bloc.dart';

sealed class ProductDetailEvent {
  const ProductDetailEvent();
}

final class ProductDetailStarted extends ProductDetailEvent {
  const ProductDetailStarted(this.productId);

  final String productId;
}

final class ProductQuantityIncremented extends ProductDetailEvent {
  const ProductQuantityIncremented();
}

final class ProductQuantityDecremented extends ProductDetailEvent {
  const ProductQuantityDecremented();
}

final class ProductAddToCartPressed extends ProductDetailEvent {
  const ProductAddToCartPressed();
}
