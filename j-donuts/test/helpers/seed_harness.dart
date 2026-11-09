import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/seed/catalog_import_runner.dart';
import 'package:jdonuts/core/database/seed/seed_bundle_loader.dart';
import 'package:jdonuts/core/database/seed/seed_service.dart';
import 'package:jdonuts/core/database/unit_of_work.dart';
import 'package:jdonuts/core/member/data/datasources/member_catalog_importer.dart';
import 'package:jdonuts/module/home/di/home_injection.dart';
import 'package:jdonuts/module/product/di/product_injection.dart';
import 'package:jdonuts/module/rewards/di/rewards_injection.dart';

import 'test_doubles.dart';

/// The same importer set the app registers, built over [database].
CatalogImportRunner catalogRunnerFor(AppDatabase database) {
  final locator = GetIt.asNewInstance()..registerSingleton(database);
  return CatalogImportRunner([
    MemberCatalogImporter(database.memberDao),
    ...productCatalogImporters(locator),
    ...rewardsCatalogImporters(locator),
    ...homeCatalogImporters(locator),
  ]);
}

/// SeedService reading the real bundled catalog.
SeedService seedServiceFor(
  AppDatabase database, {
  int version = SeedService.seedVersion,
  SeedBundleLoader? loader,
}) => SeedService(
  appMetaDao: database.appMetaDao,
  loader: loader ?? SeedBundleLoader(rootBundle),
  runner: catalogRunnerFor(database),
  unitOfWork: DriftUnitOfWork(database),
  logger: silentLogger(),
  version: version,
);
