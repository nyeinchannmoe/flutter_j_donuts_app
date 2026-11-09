import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_section.freezed.dart';

/// Product rails on Home. Names match the `kind` values in catalog data.
enum HomeSectionKind { seasonal, popular, orderAgain }

@freezed
abstract class SectionProduct with _$SectionProduct {
  const factory SectionProduct({
    required String productId,
    required String name,
    required int priceMmk,
    required String imageAsset,
    String? imageUrl,
    String? subtitle,
    int? discountPercent,
  }) = _SectionProduct;
}

@freezed
abstract class HomeSection with _$HomeSection {
  const factory HomeSection({
    required String id,
    required HomeSectionKind kind,
    required String title,
    required List<SectionProduct> items,
  }) = _HomeSection;
}
