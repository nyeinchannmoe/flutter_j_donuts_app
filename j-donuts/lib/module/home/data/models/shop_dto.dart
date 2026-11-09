import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_dto.freezed.dart';
part 'shop_dto.g.dart';

@freezed
abstract class ShopDto with _$ShopDto {
  const factory ShopDto({
    required String id,
    required String name,
    required String address,
    required String imageAsset,
    required int sortOrder,
    String? imageUrl,
  }) = _ShopDto;

  factory ShopDto.fromJson(Map<String, Object?> json) =>
      _$ShopDtoFromJson(json);
}
