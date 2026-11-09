import 'package:get_it/get_it.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/seed/catalog_importer.dart';
import 'package:jdonuts/module/home/data/datasources/home_catalog_importers.dart';
import 'package:jdonuts/module/home/data/repositories/home_repository_impl.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/domain/repositories/home_repository.dart';
import 'package:jdonuts/module/home/domain/usecases/refresh_home_content.dart';
import 'package:jdonuts/module/home/domain/usecases/watch_banners.dart';
import 'package:jdonuts/module/home/domain/usecases/watch_home_section.dart';
import 'package:jdonuts/module/home/domain/usecases/watch_shops.dart';
import 'package:jdonuts/module/home/presentation/bloc/banners/banners_bloc.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_refresh/home_refresh_bloc.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_section/home_section_bloc.dart';
import 'package:jdonuts/module/home/presentation/bloc/member_header/member_header_bloc.dart';
import 'package:jdonuts/module/home/presentation/bloc/shops/shops_bloc.dart';

List<CatalogImporter> homeCatalogImporters(GetIt locator) {
  final dao = locator<AppDatabase>().homeDao;
  return [
    BannersCatalogImporter(dao),
    ShopsCatalogImporter(dao),
    HomeSectionsCatalogImporter(dao),
  ];
}

void registerHomeModule(GetIt locator) {
  locator
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(
        dao: locator<AppDatabase>().homeDao,
        syncCoordinator: locator(),
        logger: locator(),
      ),
    )
    ..registerFactory(() => WatchBanners(locator()))
    ..registerFactory(() => WatchHomeSection(locator()))
    ..registerFactory(() => WatchShops(locator()))
    ..registerFactory(() => RefreshHomeContent(locator()))
    ..registerFactory(() => MemberHeaderBloc(watchMemberProfile: locator()))
    ..registerFactory(() => BannersBloc(watchBanners: locator()))
    ..registerFactory(() => ShopsBloc(watchShops: locator()))
    ..registerFactory(() => HomeRefreshBloc(refreshHomeContent: locator()))
    ..registerFactoryParam<HomeSectionBloc, HomeSectionKind, void>(
      (kind, _) => HomeSectionBloc(watchHomeSection: locator(), kind: kind),
    );
}
