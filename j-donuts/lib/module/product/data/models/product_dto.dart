import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_dto.freezed.dart';
part 'product_dto.g.dart';

/// JSON shape of a product, matching the record in the code test brief.
@freezed
abstract class ProductDto with _$ProductDto {
  const factory ProductDto({
    required String id,
    required String code,
    required String name,
    required int priceMmk,
    required bool isNew,
    required String imageAsset,
    required String description,
    String? imageUrl,
  }) = _ProductDto;

  factory ProductDto.fromJson(Map<String, Object?> json) =>
      _$ProductDtoFromJson(json);
}
