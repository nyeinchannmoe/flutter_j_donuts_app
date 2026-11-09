import 'package:jdonuts/core/database/daos/products_dao.dart';
import 'package:jdonuts/core/database/seed/catalog_importer.dart';
import 'package:jdonuts/module/product/data/mappers/product_mapper.dart';
import 'package:jdonuts/module/product/data/models/product_dto.dart';

class ProductsCatalogImporter implements CatalogImporter {
  const ProductsCatalogImporter(this._dao);

  final ProductsDao _dao;

  @override
  String get sectionKey => 'products';

  @override
  ImportStage get stage => ImportStage.reference;

  @override
  bool get acceptsRemoteUpdates => true;

  @override
  Future<void> importSection(Object? json) => _dao.upsertProducts([
    for (final product in (json! as List<Object?>).cast<Map<String, Object?>>())
      ProductDto.fromJson(product).toCompanion(),
  ]);
}
