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
    required int currentTierMinPoints,
    String? photoUrl,
    String? nextTierName,
    int? nextTierMinPoints,
  }) = _MemberProfile;

  const MemberProfile._();

  bool get hasNextTier => nextTierName != null;

  /// Progress within the current→next tier band, or null at the top tier.
  double? get progressTowardNextTier {
    final nextMin = nextTierMinPoints;
    if (nextMin == null) return null;
    final span = nextMin - currentTierMinPoints;
    if (span <= 0) return 1;
    return ((totalPoints - currentTierMinPoints) / span).clamp(0.0, 1.0);
  }
}
