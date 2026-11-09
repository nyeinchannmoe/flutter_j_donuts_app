import 'package:jdonuts/core/database/daos/products_dao.dart';
import 'package:jdonuts/core/error/app_exception.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/error/guard.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/product/data/mappers/product_mapper.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';
import 'package:jdonuts/module/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({
    required this._dao,
    required this._logger,
  });

  final ProductsDao _dao;
  final AppLogger _logger;

  @override
  Future<Result<Product>> getProduct(String id) => guardResult(() async {
    final row = await _dao.findById(id);
    if (row == null) {
      throw AppException(NotFoundFailure(cause: 'Product $id'));
    }
    return row.toEntity();
  }, logger: _logger);
}
