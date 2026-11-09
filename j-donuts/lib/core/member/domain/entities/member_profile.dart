import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_profile.freezed.dart';

/// The single member record shown on Home and Rewards.
@freezed
abstract class MemberProfile with _$MemberProfile {
  const factory MemberProfile({
    required String name,
    required String photoAsset,
    required String tierId,
    required String tierName,
    required int tierRank,
    required int totalPoints,
    required int pointsToNextTier,
    required int notificationsCount,
    required int pendingRewardsCount,
    String? photoUrl,
    String? nextTierName,
  }) = _MemberProfile;

  const MemberProfile._();

  bool get hasNextTier => nextTierName != null;
}
