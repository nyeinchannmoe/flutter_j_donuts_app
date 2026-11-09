import 'package:get_it/get_it.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/seed/catalog_importer.dart';
import 'package:jdonuts/module/product/data/datasources/products_catalog_importer.dart';
import 'package:jdonuts/module/product/data/repositories/cart_repository_impl.dart';
import 'package:jdonuts/module/product/data/repositories/product_repository_impl.dart';
import 'package:jdonuts/module/product/domain/repositories/cart_repository.dart';
import 'package:jdonuts/module/product/domain/repositories/product_repository.dart';
import 'package:jdonuts/module/product/domain/usecases/add_to_cart.dart';
import 'package:jdonuts/module/product/domain/usecases/get_product.dart';
import 'package:jdonuts/module/product/presentation/bloc/product_detail/product_detail_bloc.dart';

List<CatalogImporter> productCatalogImporters(GetIt locator) => [
  ProductsCatalogImporter(locator<AppDatabase>().productsDao),
];

void registerProductModule(GetIt locator) {
  final database = locator<AppDatabase>();
  locator
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(dao: database.productsDao, logger: locator()),
    )
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(dao: database.cartDao, logger: locator()),
    )
    ..registerFactory(() => GetProduct(locator()))
    ..registerFactory(() => AddToCart(locator()))
    ..registerFactory(
      () => ProductDetailBloc(getProduct: locator(), addToCart: locator()),
    );
}
