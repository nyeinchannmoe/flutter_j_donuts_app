import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/module/product/domain/entities/cart_rules.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';
import 'package:jdonuts/module/product/domain/usecases/add_to_cart.dart';
import 'package:jdonuts/module/product/domain/usecases/get_product.dart';

part 'product_detail_bloc.freezed.dart';
part 'product_detail_event.dart';
part 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc({
    required this._getProduct,
    required this._addToCart,
  }) : super(const ProductDetailState()) {
    on<ProductDetailStarted>(_onStarted, transformer: restartable());
    on<ProductQuantityIncremented>(_onIncremented, transformer: sequential());
    on<ProductQuantityDecremented>(_onDecremented, transformer: sequential());
    on<ProductAddToCartPressed>(_onAddToCart, transformer: droppable());
  }

  final GetProduct _getProduct;
  final AddToCart _addToCart;

  Future<void> _onStarted(
    ProductDetailStarted event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(state.copyWith(product: const ViewState.loading()));
    final result = await _getProduct(event.productId);
    emit(
      state.copyWith(
        product: ViewState.fromResult(result, isEmpty: (_) => false),
      ),
    );
  }

  void _onIncremented(
    ProductQuantityIncremented event,
    Emitter<ProductDetailState> emit,
  ) {
    if (state.quantity >= CartRules.maxQuantity) return;
    emit(state.copyWith(quantity: state.quantity + 1));
  }

  void _onDecremented(
    ProductQuantityDecremented event,
    Emitter<ProductDetailState> emit,
  ) {
    if (state.quantity <= CartRules.minQuantity) return;
    emit(state.copyWith(quantity: state.quantity - 1));
  }

  Future<void> _onAddToCart(
    ProductAddToCartPressed event,
    Emitter<ProductDetailState> emit,
  ) async {
    final product = state.productOrNull;
    if (product == null) return;
    emit(state.copyWith(cartStatus: CartStatus.adding, cartFailure: null));
    final result = await _addToCart(
      productId: product.id,
      quantity: state.quantity,
    );
    emit(switch (result) {
      Ok() => state.copyWith(
        cartStatus: CartStatus.added,
        lastAddedQuantity: state.quantity,
      ),
      Err(:final failure) => state.copyWith(
        cartStatus: CartStatus.failed,
        cartFailure: failure,
      ),
    });
  }
}
