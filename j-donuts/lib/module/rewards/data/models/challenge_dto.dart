import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_dto.freezed.dart';
part 'challenge_dto.g.dart';

@freezed
abstract class ChallengeDto with _$ChallengeDto {
  const factory ChallengeDto({
    required String id,
    required String title,
    required String kind,
    required int progressCurrent,
    required int progressTarget,
    required int rewardPoints,
    required String imageAsset,
    required int sortOrder,
  }) = _ChallengeDto;

  factory ChallengeDto.fromJson(Map<String, Object?> json) =>
      _$ChallengeDtoFromJson(json);
}
