import 'package:jdonuts/core/database/daos/app_meta_dao.dart';
import 'package:jdonuts/core/database/seed/catalog_import_runner.dart';
import 'package:jdonuts/core/database/seed/catalog_importer.dart';
import 'package:jdonuts/core/database/seed/seed_bundle_loader.dart';
import 'package:jdonuts/core/database/unit_of_work.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/error/guard.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/result/result.dart';

enum SeedOutcome { seeded, alreadyCurrent }

/// Seeds the database from the bundled catalog once per [seedVersion].
///
/// Idempotent: a matching stored version skips all work. A new version
/// upserts catalog rows inside one transaction together with the version
/// marker, so a crash mid-seed leaves the previous state intact. Tables the
/// catalog does not contain (cart, local users) are never touched.
class SeedService {
  SeedService({
    required this._appMetaDao,
    required this._loader,
    required this._runner,
    required this._unitOfWork,
    required this._logger,
    this._version = seedVersion,
  });

  /// Bump when assets/seed/catalog.json changes.
  static const int seedVersion = 1;

  final AppMetaDao _appMetaDao;
  final SeedBundleLoader _loader;
  final CatalogImportRunner _runner;
  final UnitOfWork _unitOfWork;
  final AppLogger _logger;
  final int _version;

  Future<Result<SeedOutcome>> ensureSeeded() => guardResult(
    _seedIfNeeded,
    logger: _logger,
    fallback: (error, stackTrace) => StorageFailure(
      code: FailureCodes.seed,
      cause: error,
      stackTrace: stackTrace,
    ),
  );

  Future<SeedOutcome> _seedIfNeeded() async {
    final stored = await _appMetaDao.readValue(AppMetaKeys.seedVersion);
    if (stored == '$_version') return SeedOutcome.alreadyCurrent;
    final payload = await _loader.load();
    await _unitOfWork.run(() async {
      await _runner.importAll(payload, source: ImportSource.bundledSeed);
      await _appMetaDao.writeValue(AppMetaKeys.seedVersion, '$_version');
    });
    _logger.info('Seeded catalog version $_version (was ${stored ?? 'none'})');
    return SeedOutcome.seeded;
  }
}
