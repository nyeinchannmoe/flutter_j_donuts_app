import 'package:jdonuts/core/database/daos/home_dao.dart';
import 'package:jdonuts/core/database/seed/catalog_importer.dart';
import 'package:jdonuts/module/home/data/mappers/home_mappers.dart';
import 'package:jdonuts/module/home/data/models/banner_dto.dart';
import 'package:jdonuts/module/home/data/models/home_section_dto.dart';
import 'package:jdonuts/module/home/data/models/shop_dto.dart';

List<Map<String, Object?>> _objects(Object? json) =>
    (json! as List<Object?>).cast<Map<String, Object?>>();

class BannersCatalogImporter implements CatalogImporter {
  const BannersCatalogImporter(this._dao);

  final HomeDao _dao;

  @override
  String get sectionKey => 'banners';

  @override
  ImportStage get stage => ImportStage.reference;

  @override
  bool get acceptsRemoteUpdates => true;

  @override
  Future<void> importSection(Object? json) => _dao.replaceBanners([
    for (final banner in _objects(json))
      BannerDto.fromJson(banner).toCompanion(),
  ]);
}

class ShopsCatalogImporter implements CatalogImporter {
  const ShopsCatalogImporter(this._dao);

  final HomeDao _dao;

  @override
  String get sectionKey => 'shops';

  @override
  ImportStage get stage => ImportStage.reference;

  @override
  bool get acceptsRemoteUpdates => true;

  @override
  Future<void> importSection(Object? json) => _dao.replaceShops([
    for (final shop in _objects(json)) ShopDto.fromJson(shop).toCompanion(),
  ]);
}

/// Depends on products, so it runs in the dependent stage.
class HomeSectionsCatalogImporter implements CatalogImporter {
  const HomeSectionsCatalogImporter(this._dao);

  final HomeDao _dao;

  @override
  String get sectionKey => 'homeSections';

  @override
  ImportStage get stage => ImportStage.dependent;

  @override
  bool get acceptsRemoteUpdates => true;

  @override
  Future<void> importSection(Object? json) => _dao.replaceSections([
    for (final section in _objects(json))
      HomeSectionDto.fromJson(section).toWrite(),
  ]);
}
