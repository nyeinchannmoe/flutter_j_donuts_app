import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_section_dto.freezed.dart';
part 'home_section_dto.g.dart';

@freezed
abstract class HomeSectionItemDto with _$HomeSectionItemDto {
  const factory HomeSectionItemDto({
    required String productId,
    required int sortOrder,
    int? discountPercent,
  }) = _HomeSectionItemDto;

  factory HomeSectionItemDto.fromJson(Map<String, Object?> json) =>
      _$HomeSectionItemDtoFromJson(json);
}

@freezed
abstract class HomeSectionDto with _$HomeSectionDto {
  const factory HomeSectionDto({
    required String id,
    required String kind,
    required String title,
    required int sortOrder,
    required List<HomeSectionItemDto> items,
  }) = _HomeSectionDto;

  factory HomeSectionDto.fromJson(Map<String, Object?> json) =>
      _$HomeSectionDtoFromJson(json);
}
