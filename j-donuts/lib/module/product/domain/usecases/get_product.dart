import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';
import 'package:jdonuts/module/product/domain/repositories/product_repository.dart';

class GetProduct {
  const GetProduct(this._repository);

  final ProductRepository _repository;

  Future<Result<Product>> call(String id) => _repository.getProduct(id);
}
