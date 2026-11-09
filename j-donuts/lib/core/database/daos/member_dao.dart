import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/tables/member_profile_table.dart';
import 'package:jdonuts/core/database/tables/tiers_table.dart';

part 'member_dao.g.dart';

/// Member profile joined with its current tier and the next tier up.
typedef MemberWithTier = ({
  MemberProfileRow member,
  TierRow tier,
  TierRow? nextTier,
});

@DriftAccessor(tables: [MemberProfiles, Tiers])
class MemberDao extends DatabaseAccessor<AppDatabase> with _$MemberDaoMixin {
  MemberDao(super.attachedDatabase);

  /// Emits null until the member row is seeded.
  Stream<MemberWithTier?> watchMemberWithTier() {
    final nextTier = alias(tiers, 'next_tier');
    final query =
        select(memberProfiles).join([
            innerJoin(tiers, tiers.id.equalsExp(memberProfiles.tierId)),
            leftOuterJoin(
              nextTier,
              nextTier.minPoints.isBiggerThan(tiers.minPoints),
            ),
          ])
          ..orderBy([OrderingTerm.asc(nextTier.minPoints)])
          ..limit(1);
    return query.watchSingleOrNull().map(
      (row) => row == null
          ? null
          : (
              member: row.readTable(memberProfiles),
              tier: row.readTable(tiers),
              nextTier: row.readTableOrNull(nextTier),
            ),
    );
  }

  Stream<List<TierRow>> watchTiers() {
    final query = select(tiers)
      ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]);
    return query.watch();
  }

  Future<void> upsertTiers(List<TiersCompanion> rows) => batch(
    (batch) => batch.insertAllOnConflictUpdate(tiers, rows),
  );

  Future<void> upsertMember(MemberProfilesCompanion row) =>
      into(memberProfiles).insertOnConflictUpdate(row);
}
