import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/daos/member_dao.dart';
import 'package:jdonuts/core/database/tables/member_profile_table.dart';
import 'package:jdonuts/core/member/data/models/member_dto.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';

extension MemberDtoMapper on MemberDto {
  MemberProfilesCompanion toCompanion() => MemberProfilesCompanion.insert(
    id: const Value(MemberProfiles.singletonId),
    name: name,
    photoUrl: Value(photoUrl),
    photoAsset: photoAsset,
    tierId: tierId,
    totalPoints: totalPoints,
    pointsToNextTier: pointsToNextTier,
    notificationsCount: notificationsCount,
    pendingRewardsCount: pendingRewardsCount,
  );
}

extension MemberRowMapper on MemberWithTier {
  MemberProfile toEntity() => MemberProfile(
    name: member.name,
    photoUrl: member.photoUrl,
    photoAsset: member.photoAsset,
    tierId: tier.id,
    tierName: tier.name,
    tierRank: tier.sortOrder,
    totalPoints: member.totalPoints,
    pointsToNextTier: member.pointsToNextTier,
    nextTierName: nextTier?.name,
    notificationsCount: member.notificationsCount,
    pendingRewardsCount: member.pendingRewardsCount,
  );
}
