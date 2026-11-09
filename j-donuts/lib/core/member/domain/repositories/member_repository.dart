import 'package:jdonuts/core/member/domain/entities/member_profile.dart';
import 'package:jdonuts/core/result/result.dart';

/// Shared contract for the member record. Home and Rewards both depend on
/// this so they can never disagree about tier or points.
abstract interface class MemberRepository {
  /// Emits null while the member has not been seeded.
  Stream<Result<MemberProfile?>> watchMember();
}
