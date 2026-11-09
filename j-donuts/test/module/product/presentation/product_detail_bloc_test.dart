import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/module/product/domain/entities/cart_rules.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';
import 'package:jdonuts/module/product/domain/usecases/add_to_cart.dart';
import 'package:jdonuts/module/product/domain/usecases/get_product.dart';
import 'package:jdonuts/module/product/presentation/bloc/product_detail/product_detail_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetProduct extends Mock implements GetProduct {}

class _MockAddToCart extends Mock implements AddToCart {}

const Product _product = Product(
  id: 'p_coconut',
  code: 'JD-001',
  name: 'Coconut',
  priceMmk: 2500,
  isNew: true,
  imageAsset: 'assets/seed/images/p_coconut.webp',
  description: 'Coconut glaze.',
);

const ProductDetailState _loaded = ProductDetailState(
  product: ViewState.data(_product),
);

void main() {
  late _MockGetProduct getProduct;
  late _MockAddToCart addToCart;

  setUp(() {
    getProduct = _MockGetProduct();
    addToCart = _MockAddToCart();
  });

  ProductDetailBloc build() =>
      ProductDetailBloc(getProduct: getProduct, addToCart: addToCart);

  group('ProductDetailBloc', () {
    blocTest<ProductDetailBloc, ProductDetailState>(
      'loads the product',
      setUp: () => when(
        () => getProduct(_product.id),
      ).thenAnswer((_) async => const Ok(_product)),
      build: build,
      act: (bloc) => bloc.add(ProductDetailStarted(_product.id)),
      expect: () => const [ProductDetailState(), _loaded],
    );

    blocTest<ProductDetailBloc, ProductDetailState>(
      'shows not found for an unknown id',
      setUp: () => when(
        () => getProduct('missing'),
      ).thenAnswer((_) async => const Err(NotFoundFailure())),
      build: build,
      act: (bloc) => bloc.add(const ProductDetailStarted('missing')),
      expect: () => const [
        ProductDetailState(),
        ProductDetailState(product: ViewState.failure(NotFoundFailure())),
      ],
    );

    blocTest<ProductDetailBloc, ProductDetailState>(
      'quantity moves within the cart limits and updates the total',
      build: build,
      seed: () => _loaded,
      act: (bloc) => bloc
        ..add(const ProductQuantityDecremented())
        ..add(const ProductQuantityIncremented())
        ..add(const ProductQuantityIncremented()),
      expect: () => [
        _loaded.copyWith(quantity: 2),
        _loaded.copyWith(quantity: 3),
      ],
      verify: (bloc) => expect(bloc.state.totalMmk, 3 * _product.priceMmk),
    );

    blocTest<ProductDetailBloc, ProductDetailState>(
      'does not exceed the maximum quantity',
      build: build,
      seed: () => _loaded.copyWith(quantity: CartRules.maxQuantity),
      act: (bloc) => bloc.add(const ProductQuantityIncremented()),
      expect: () => const <ProductDetailState>[],
    );

    blocTest<ProductDetailBloc, ProductDetailState>(
      'adds the chosen quantity to the cart',
      setUp: () => when(
        () => addToCart(productId: _product.id, quantity: 2),
      ).thenAnswer((_) async => const Ok(2)),
      build: build,
      seed: () => _loaded.copyWith(quantity: 2),
      act: (bloc) => bloc.add(const ProductAddToCartPressed()),
      expect: () => [
        _loaded.copyWith(quantity: 2, cartStatus: CartStatus.adding),
        _loaded.copyWith(
          quantity: 2,
          cartStatus: CartStatus.added,
          lastAddedQuantity: 2,
        ),
      ],
    );

    blocTest<ProductDetailBloc, ProductDetailState>(
      'reports a cart failure',
      setUp: () => when(
        () => addToCart(productId: _product.id, quantity: 1),
      ).thenAnswer((_) async => const Err(StorageFailure())),
      build: build,
      seed: () => _loaded,
      act: (bloc) => bloc.add(const ProductAddToCartPressed()),
      expect: () => [
        _loaded.copyWith(cartStatus: CartStatus.adding),
        _loaded.copyWith(
          cartStatus: CartStatus.failed,
          cartFailure: const StorageFailure(),
        ),
      ],
    );

    blocTest<ProductDetailBloc, ProductDetailState>(
      'ignores add to cart before the product loads',
      build: build,
      act: (bloc) => bloc.add(const ProductAddToCartPressed()),
      expect: () => const <ProductDetailState>[],
      verify: (_) => verifyNever(
        () => addToCart(
          productId: any(named: 'productId'),
          quantity: any(named: 'quantity'),
        ),
      ),
    );
  });
}
