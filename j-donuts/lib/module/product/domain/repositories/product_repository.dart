import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';

abstract interface class ProductRepository {
  /// Fails with NotFoundFailure when [id] does not exist.
  Future<Result<Product>> getProduct(String id);
}
