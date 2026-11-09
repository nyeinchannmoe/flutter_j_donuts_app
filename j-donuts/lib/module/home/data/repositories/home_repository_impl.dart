import 'package:jdonuts/core/database/daos/home_dao.dart';
import 'package:jdonuts/core/error/guard.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/sync/sync_coordinator.dart';
import 'package:jdonuts/core/sync/sync_policy.dart';
import 'package:jdonuts/module/home/data/mappers/home_mappers.dart';
import 'package:jdonuts/module/home/domain/entities/home_banner.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/domain/entities/shop.dart';
import 'package:jdonuts/module/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({
    required this._dao,
    required this._syncCoordinator,
    required this._logger,
  });

  final HomeDao _dao;
  final SyncCoordinator _syncCoordinator;
  final AppLogger _logger;

  @override
  Stream<Result<List<HomeBanner>>> watchBanners() => guardStream(
    _dao.watchBanners().map(
      (rows) => [for (final row in rows) row.toEntity()],
    ),
    logger: _logger,
  );

  @override
  Stream<Result<HomeSection?>> watchSection(HomeSectionKind kind) =>
      guardStream(
        _dao.watchSection(kind.name).map((row) => row?.toEntity()),
        logger: _logger,
      );

  @override
  Stream<Result<List<Shop>>> watchShops() => guardStream(
    _dao.watchShops().map((rows) => [for (final row in rows) row.toEntity()]),
    logger: _logger,
  );

  @override
  Future<Result<Unit>> refresh() async {
    final result = await _syncCoordinator.requestSync(
      SyncTrigger.pullToRefresh,
    );
    return result.map((_) => Unit.value);
  }
}
