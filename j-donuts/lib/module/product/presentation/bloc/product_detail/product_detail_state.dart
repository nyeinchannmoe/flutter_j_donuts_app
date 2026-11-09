part of 'product_detail_bloc.dart';

/// Add-to-cart progress. Each press moves adding then added or failed, so
/// listeners react to the transition instead of a flag to reset.
enum CartStatus { idle, adding, added, failed }

@freezed
abstract class ProductDetailState with _$ProductDetailState {
  const factory ProductDetailState({
    @Default(ViewState<Product>.loading()) ViewState<Product> product,
    @Default(CartRules.minQuantity) int quantity,
    @Default(CartStatus.idle) CartStatus cartStatus,
    @Default(0) int lastAddedQuantity,
    AppFailure? cartFailure,
  }) = _ProductDetailState;

  const ProductDetailState._();

  Product? get productOrNull => switch (product) {
    ViewData<Product>(:final value) => value,
    _ => null,
  };

  /// Live total for the current quantity, zero until the product loads.
  int get totalMmk => CartRules.lineTotal(
    unitPriceMmk: productOrNull?.priceMmk ?? 0,
    quantity: quantity,
  );

  bool get canDecrement => quantity > CartRules.minQuantity;

  bool get canIncrement => quantity < CartRules.maxQuantity;
}
