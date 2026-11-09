import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/daos/home_dao.dart';
import 'package:jdonuts/module/home/data/models/banner_dto.dart';
import 'package:jdonuts/module/home/data/models/home_section_dto.dart';
import 'package:jdonuts/module/home/data/models/shop_dto.dart';
import 'package:jdonuts/module/home/domain/entities/home_banner.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/domain/entities/shop.dart';

extension BannerDtoMapper on BannerDto {
  BannersCompanion toCompanion() => BannersCompanion.insert(
    id: id,
    tag: Value(tag),
    title: title,
    imageUrl: Value(imageUrl),
    imageAsset: imageAsset,
    cardTone: Value(cardTone),
    sortOrder: sortOrder,
  );
}

extension BannerRowMapper on BannerRow {
  HomeBanner toEntity() => HomeBanner(
    id: id,
    title: title,
    tag: tag,
    imageAsset: imageAsset,
    imageUrl: imageUrl,
    cardTone: cardTone,
  );
}

extension ShopDtoMapper on ShopDto {
  ShopsCompanion toCompanion() => ShopsCompanion.insert(
    id: id,
    name: name,
    address: address,
    imageUrl: Value(imageUrl),
    imageAsset: imageAsset,
    sortOrder: sortOrder,
  );
}

extension ShopRowMapper on ShopRow {
  Shop toEntity() => Shop(
    id: id,
    name: name,
    address: address,
    imageAsset: imageAsset,
    imageUrl: imageUrl,
  );
}

extension HomeSectionDtoMapper on HomeSectionDto {
  /// Throws ArgumentError for an unknown kind so bad data fails the import
  /// instead of silently disappearing.
  SectionWrite toWrite() {
    HomeSectionKind.values.byName(kind);
    return (
      section: HomeSectionsCompanion.insert(
        id: id,
        kind: kind,
        title: title,
        sortOrder: sortOrder,
      ),
      items: [
        for (final item in items)
          HomeSectionItemsCompanion.insert(
            sectionId: id,
            productId: item.productId,
            sortOrder: item.sortOrder,
            discountPercent: Value(item.discountPercent),
          ),
      ],
    );
  }
}

extension SectionWithItemsMapper on SectionWithItems {
  HomeSection toEntity() => HomeSection(
    id: section.id,
    kind: HomeSectionKind.values.byName(section.kind),
    title: section.title,
    items: [
      for (final entry in items)
        SectionProduct(
          productId: entry.product.id,
          name: entry.product.name,
          priceMmk: entry.product.priceMmk,
          imageAsset: entry.product.imageAsset,
          imageUrl: entry.product.imageUrl,
          subtitle: entry.product.subtitle,
          discountPercent: entry.item.discountPercent,
        ),
    ],
  );
}
