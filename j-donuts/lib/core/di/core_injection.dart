import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:jdonuts/core/connectivity/connectivity_cubit.dart';
import 'package:jdonuts/core/connectivity/connectivity_service.dart';
import 'package:jdonuts/core/connectivity/reachability_checker.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/seed/catalog_import_runner.dart';
import 'package:jdonuts/core/database/seed/catalog_importer.dart';
import 'package:jdonuts/core/database/seed/seed_bundle_loader.dart';
import 'package:jdonuts/core/database/seed/seed_service.dart';
import 'package:jdonuts/core/database/unit_of_work.dart';
import 'package:jdonuts/core/images/app_image_cache_manager.dart';
import 'package:jdonuts/core/locale/locale_preference_store.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/member/data/datasources/member_catalog_importer.dart';
import 'package:jdonuts/core/member/data/repositories/member_repository_impl.dart';
import 'package:jdonuts/core/member/domain/repositories/member_repository.dart';
import 'package:jdonuts/core/member/domain/usecases/watch_member_profile.dart';
import 'package:jdonuts/core/motion/frame_budget_monitor.dart';
import 'package:jdonuts/core/motion/motion_policy.dart';
import 'package:jdonuts/core/network/dio_factory.dart';
import 'package:jdonuts/core/network/remote_data_source.dart';
import 'package:jdonuts/core/storage/secure_key_value_store.dart';
import 'package:jdonuts/core/storage/session_store.dart';
import 'package:jdonuts/core/sync/app_lifecycle_sync_binding.dart';
import 'package:jdonuts/core/sync/sync_coordinator.dart';
import 'package:jdonuts/core/utils/clock.dart';
import 'package:jdonuts/core/utils/interval_ticker.dart';

/// Core values derived from AppConfig, so core never imports config.
class CoreSettings {
  const CoreSettings({required this.reachabilityHost, this.remoteBaseUrl});

  /// Null keeps the app on NoopRemoteDataSource.
  final String? remoteBaseUrl;
  final String reachabilityHost;
}

void registerCoreServices(
  GetIt locator, {
  required CoreSettings settings,
  required AppLogger logger,
  required AppDatabase database,
  required AssetBundle bundle,
}) {
  locator
    ..registerSingleton<AppLogger>(logger)
    ..registerSingleton<AppDatabase>(
      database,
      dispose: (database) => database.close(),
    )
    ..registerLazySingleton<UnitOfWork>(() => DriftUnitOfWork(database))
    ..registerLazySingleton(() => SeedBundleLoader(bundle))
    ..registerLazySingleton(
      () => SessionStore(store: FlutterSecureKeyValueStore(), logger: logger),
    )
    ..registerLazySingleton(
      () => LocalePreferenceStore(dao: database.appMetaDao, logger: logger),
    )
    ..registerLazySingleton(AppImageCacheManager.new)
    ..registerLazySingleton<MemberRepository>(
      () => MemberRepositoryImpl(dao: database.memberDao, logger: logger),
    )
    ..registerFactory(() => WatchMemberProfile(locator()));
  _registerPlatformServices(locator, settings: settings, logger: logger);
}

void _registerPlatformServices(
  GetIt locator, {
  required CoreSettings settings,
  required AppLogger logger,
}) {
  locator
    ..registerLazySingleton<Clock>(SystemClock.new)
    ..registerLazySingleton<IntervalTicker>(SystemIntervalTicker.new)
    ..registerLazySingleton(
      () => MotionPolicy(monitor: FrameBudgetMonitor(logger: logger)),
      dispose: (policy) => policy.dispose(),
    )
    ..registerLazySingleton<RemoteDataSource>(
      () => _remoteDataSource(settings.remoteBaseUrl, logger),
    )
    ..registerLazySingleton(
      () => ConnectivityService(
        connectivity: Connectivity(),
        reachability: DnsReachabilityChecker(host: settings.reachabilityHost),
      ),
      dispose: (service) => service.dispose(),
    );
}

RemoteDataSource _remoteDataSource(String? baseUrl, AppLogger logger) =>
    baseUrl == null
    ? const NoopRemoteDataSource()
    : DioRemoteDataSource(
        dio: DioFactory.create(baseUrl: baseUrl, logger: logger),
        logger: logger,
      );

/// Registers the importer runner and everything that writes catalog data.
void registerCatalogPipeline(
  GetIt locator, {
  required List<CatalogImporter> importers,
}) {
  final database = locator<AppDatabase>();
  locator
    ..registerLazySingleton(
      () => CatalogImportRunner([
        MemberCatalogImporter(database.memberDao),
        ...importers,
      ]),
    )
    ..registerLazySingleton(
      () => SeedService(
        appMetaDao: database.appMetaDao,
        loader: locator(),
        runner: locator(),
        unitOfWork: locator(),
        logger: locator(),
      ),
    );
  _registerSync(locator, database);
}

void _registerSync(GetIt locator, AppDatabase database) {
  locator
    ..registerLazySingleton(
      () => SyncCoordinator(
        remote: locator(),
        runner: locator(),
        unitOfWork: locator(),
        appMetaDao: database.appMetaDao,
        logger: locator(),
      ),
      dispose: (coordinator) => coordinator.dispose(),
    )
    ..registerLazySingleton(
      () => AppLifecycleSyncBinding(
        syncCoordinator: locator(),
        connectivityService: locator(),
      ),
      dispose: (binding) => binding.detach(),
    )
    ..registerFactory(
      () => ConnectivityCubit(service: locator(), syncCoordinator: locator()),
    );
}
