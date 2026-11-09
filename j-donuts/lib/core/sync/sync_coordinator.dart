import 'dart:async';

import 'package:jdonuts/core/database/daos/app_meta_dao.dart';
import 'package:jdonuts/core/database/seed/catalog_import_runner.dart';
import 'package:jdonuts/core/database/seed/catalog_importer.dart';
import 'package:jdonuts/core/database/unit_of_work.dart';
import 'package:jdonuts/core/error/guard.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/network/remote_data_source.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/sync/sync_policy.dart';
import 'package:jdonuts/core/sync/sync_status.dart';
import 'package:jdonuts/core/utils/clock.dart';

/// The only entry point for refreshing local data from the remote source.
///
/// Single-flight: concurrent requests share the running sync. Remote data
/// is written through the catalog importers inside one transaction, and
/// failures are reported on [status] without clearing cached content.
class SyncCoordinator {
  SyncCoordinator({
    required this._remote,
    required this._runner,
    required this._unitOfWork,
    required this._appMetaDao,
    required this._logger,
    this._policy = const SyncPolicy(),
    this._clock = const SystemClock(),
  });

  final RemoteDataSource _remote;
  final CatalogImportRunner _runner;
  final UnitOfWork _unitOfWork;
  final AppMetaDao _appMetaDao;
  final AppLogger _logger;
  final SyncPolicy _policy;
  final Clock _clock;

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  SyncStatus _current = const SyncIdle();
  Future<Result<SyncStatus>>? _inFlight;

  SyncStatus get currentStatus => _current;

  Stream<SyncStatus> get status => _statusController.stream;

  Future<Result<SyncStatus>> requestSync(SyncTrigger trigger) =>
      _inFlight ??= _run(trigger).whenComplete(() => _inFlight = null);

  Future<Result<SyncStatus>> _run(SyncTrigger trigger) async {
    final lastSyncResult = await guardResult(_readLastSync, logger: _logger);
    final lastSyncAt = lastSyncResult.valueOrNull;
    final now = _clock.now();
    if (!_policy.shouldSync(
      trigger: trigger,
      lastSyncAt: lastSyncAt,
      now: now,
    )) {
      return Ok(_emit(const SyncSkipped()));
    }
    _emit(const SyncInProgress());
    final fetched = await _remote.fetchCatalog();
    final applied = await switch (fetched) {
      Ok(:final value) => guardResult(() => _apply(value), logger: _logger),
      Err(:final failure) => Future.value(Err<DateTime>(failure)),
    };
    return applied.fold(
      onOk: (completedAt) => Ok(_emit(SyncSucceeded(completedAt))),
      onErr: (failure) {
        _logger.warning('Sync from ${trigger.name} failed: $failure');
        _emit(SyncFailed(failure));
        return Err(failure);
      },
    );
  }

  Future<DateTime?> _readLastSync() async {
    final raw = await _appMetaDao.readValue(
      AppMetaKeys.lastSyncAt(SyncPolicy.catalogScope),
    );
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<DateTime> _apply(CatalogPayload payload) async {
    final completedAt = _clock.now();
    await _unitOfWork.run(() async {
      await _runner.importAll(payload, source: ImportSource.remote);
      await _appMetaDao.writeValue(
        AppMetaKeys.lastSyncAt(SyncPolicy.catalogScope),
        completedAt.toIso8601String(),
      );
    });
    return completedAt;
  }

  SyncStatus _emit(SyncStatus status) {
    _current = status;
    _statusController.add(status);
    return status;
  }

  Future<void> dispose() => _statusController.close();
}
