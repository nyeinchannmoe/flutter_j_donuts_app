import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:jdonuts/config/app_config.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/di/core_injection.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/module/auth/di/auth_injection.dart';
import 'package:jdonuts/module/home/di/home_injection.dart';
import 'package:jdonuts/module/product/di/product_injection.dart';
import 'package:jdonuts/module/rewards/di/rewards_injection.dart';

/// Registers every dependency by hand. Catalog importers are collected
/// from the feature modules so seeding and sync share them.
void configureDependencies(
  GetIt locator, {
  required AppConfig config,
  required AppLogger logger,
  required AppDatabase database,
  required AssetBundle bundle,
}) {
  registerCoreServices(
    locator,
    settings: CoreSettings(
      remoteBaseUrl: config.usesRemoteCatalog ? config.apiBaseUrl : null,
      reachabilityHost: config.reachabilityHost,
    ),
    logger: logger,
    database: database,
    bundle: bundle,
  );
  registerCatalogPipeline(
    locator,
    importers: [
      ...productCatalogImporters(locator),
      ...rewardsCatalogImporters(locator),
      ...homeCatalogImporters(locator),
    ],
  );
  registerAuthModule(locator);
  registerHomeModule(locator);
  registerProductModule(locator);
  registerRewardsModule(locator);
}
