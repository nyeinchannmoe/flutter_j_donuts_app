import 'package:jdonuts/core/database/daos/cart_dao.dart';
import 'package:jdonuts/core/error/guard.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/utils/clock.dart';
import 'package:jdonuts/module/product/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl({
    required this._dao,
    required this._logger,
    this._clock = const SystemClock(),
  });

  final CartDao _dao;
  final AppLogger _logger;
  final Clock _clock;

  @override
  Future<Result<int>> addToCart({
    required String productId,
    required int quantity,
  }) => guardResult(
    () => _dao.addQuantity(
      productId: productId,
      quantity: quantity,
      now: _clock.now(),
    ),
    logger: _logger,
  );
}
