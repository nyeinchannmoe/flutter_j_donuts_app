import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_dto.freezed.dart';
part 'member_dto.g.dart';

/// JSON shape of the `member` catalog section.
@freezed
abstract class MemberDto with _$MemberDto {
  const factory MemberDto({
    required String name,
    required String photoAsset,
    required String tierId,
    required int totalPoints,
    required int pointsToNextTier,
    required int notificationsCount,
    required int pendingRewardsCount,
    String? photoUrl,
  }) = _MemberDto;

  factory MemberDto.fromJson(Map<String, Object?> json) =>
      _$MemberDtoFromJson(json);
}
