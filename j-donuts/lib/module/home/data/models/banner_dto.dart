import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner_dto.freezed.dart';
part 'banner_dto.g.dart';

@freezed
abstract class BannerDto with _$BannerDto {
  const factory BannerDto({
    required String id,
    required String title,
    required String imageAsset,
    required int sortOrder,
    String? tag,
    String? imageUrl,
    String? cardTone,
  }) = _BannerDto;

  factory BannerDto.fromJson(Map<String, Object?> json) =>
      _$BannerDtoFromJson(json);
}
