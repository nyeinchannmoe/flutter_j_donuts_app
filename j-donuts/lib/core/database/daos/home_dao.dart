import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/tables/banners_table.dart';
import 'package:jdonuts/core/database/tables/home_section_items_table.dart';
import 'package:jdonuts/core/database/tables/home_sections_table.dart';
import 'package:jdonuts/core/database/tables/products_table.dart';
import 'package:jdonuts/core/database/tables/shops_table.dart';

part 'home_dao.g.dart';

/// A section item joined with the product it points to.
typedef SectionItemWithProduct = ({
  HomeSectionItemRow item,
  ProductRow product,
});

/// A home section with its ordered items.
typedef SectionWithItems = ({
  HomeSectionRow section,
  List<SectionItemWithProduct> items,
});

/// Section rows to write together with their items.
typedef SectionWrite = ({
  HomeSectionsCompanion section,
  List<HomeSectionItemsCompanion> items,
});

@DriftAccessor(
  tables: [Banners, HomeSections, HomeSectionItems, Products, Shops],
)
class HomeDao extends DatabaseAccessor<AppDatabase> with _$HomeDaoMixin {
  HomeDao(super.attachedDatabase);

  Stream<List<BannerRow>> watchBanners() {
    final query = select(banners)
      ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]);
    return query.watch();
  }

  Stream<List<ShopRow>> watchShops() {
    final query = select(shops)
      ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]);
    return query.watch();
  }

  /// Emits null when no section of [kind] exists.
  Stream<SectionWithItems?> watchSection(String kind) {
    final query =
        select(homeSections).join([
            leftOuterJoin(
              homeSectionItems,
              homeSectionItems.sectionId.equalsExp(homeSections.id),
            ),
            leftOuterJoin(
              products,
              products.id.equalsExp(homeSectionItems.productId),
            ),
          ])
          ..where(homeSections.kind.equals(kind))
          ..orderBy([OrderingTerm.asc(homeSectionItems.sortOrder)]);
    return query.watch().map(_groupSection);
  }

  SectionWithItems? _groupSection(List<TypedResult> rows) {
    if (rows.isEmpty) return null;
    final items = <SectionItemWithProduct>[];
    for (final row in rows) {
      final item = row.readTableOrNull(homeSectionItems);
      final product = row.readTableOrNull(products);
      if (item != null && product != null) {
        items.add((item: item, product: product));
      }
    }
    return (section: rows.first.readTable(homeSections), items: items);
  }

  /// Replaces the banner set so removed banners disappear.
  Future<void> replaceBanners(List<BannersCompanion> rows) =>
      transaction(() async {
        await delete(banners).go();
        await batch((batch) => batch.insertAll(banners, rows));
      });

  Future<void> replaceShops(List<ShopsCompanion> rows) => transaction(() async {
    await delete(shops).go();
    await batch((batch) => batch.insertAll(shops, rows));
  });

  /// Replaces every section and its items in one transaction.
  Future<void> replaceSections(List<SectionWrite> sections) =>
      transaction(() async {
        await delete(homeSectionItems).go();
        await delete(homeSections).go();
        await batch((batch) {
          for (final write in sections) {
            batch
              ..insert(homeSections, write.section)
              ..insertAll(homeSectionItems, write.items);
          }
        });
      });
}
