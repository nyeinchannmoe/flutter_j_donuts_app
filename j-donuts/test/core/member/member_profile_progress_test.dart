import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/member/domain/entities/member_profile.dart';

const MemberProfile _silverMember = MemberProfile(
  name: 'Hania',
  photoAsset: 'assets/seed/images/user_profile.webp',
  tierId: 't_silver',
  tierName: 'Silver',
  tierRank: 1,
  totalPoints: 680000,
  pointsToNextTier: 500,
  notificationsCount: 2,
  pendingRewardsCount: 3,
  currentTierMinPoints: 678500,
  nextTierName: 'Gold',
  nextTierMinPoints: 680500,
);

void main() {
  group('MemberProfile.progressTowardNextTier', () {
    test('returns the fraction within the current to next tier band', () {
      // (680000 - 678500) / (680500 - 678500) = 1500 / 2000 = 0.75
      expect(_silverMember.progressTowardNextTier, closeTo(0.75, 1e-9));
    });

    test('returns null when there is no next tier', () {
      final top = _silverMember.copyWith(
        nextTierName: null,
        nextTierMinPoints: null,
        pointsToNextTier: 0,
      );
      expect(top.progressTowardNextTier, isNull);
    });

    test('returns 1 when the next-tier span is non-positive', () {
      final broken = _silverMember.copyWith(
        currentTierMinPoints: 700000,
        nextTierMinPoints: 680500,
      );
      expect(broken.progressTowardNextTier, 1);
    });

    test('clamps values above the next tier minimum to 1', () {
      final over = _silverMember.copyWith(totalPoints: 900000);
      expect(over.progressTowardNextTier, 1);
    });

    test('clamps values below the current tier minimum to 0', () {
      final under = _silverMember.copyWith(totalPoints: 100000);
      expect(under.progressTowardNextTier, 0);
    });
  });
}
