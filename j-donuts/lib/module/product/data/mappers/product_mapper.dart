import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/module/product/data/models/product_dto.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';

extension ProductDtoMapper on ProductDto {
  ProductsCompanion toCompanion() => ProductsCompanion.insert(
    id: id,
    code: code,
    name: name,
    priceMmk: priceMmk,
    isNew: isNew,
    imageUrl: Value(imageUrl),
    imageAsset: imageAsset,
    description: description,
  );
}

extension ProductRowMapper on ProductRow {
  Product toEntity() => Product(
    id: id,
    code: code,
    name: name,
    priceMmk: priceMmk,
    isNew: isNew,
    imageAsset: imageAsset,
    imageUrl: imageUrl,
    description: description,
  );
}
