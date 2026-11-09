import 'package:freezed_annotation/freezed_annotation.dart';

part 'tier_dto.freezed.dart';
part 'tier_dto.g.dart';

@freezed
abstract class TierDto with _$TierDto {
  const factory TierDto({
    required String id,
    required String name,
    required int minPoints,
    required int sortOrder,
  }) = _TierDto;

  factory TierDto.fromJson(Map<String, Object?> json) =>
      _$TierDtoFromJson(json);
}
