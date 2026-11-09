import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/tables/tiers_table.dart';

/// Single-row table holding the one member record shared by Home and
/// Rewards. The check constraint keeps it to [singletonId].
@DataClassName('MemberProfileRow')
class MemberProfiles extends Table {
  static const int singletonId = 1;

  @override
  String get tableName => 'member_profile';

  // Drift CHECK constraints reference their own column getter.
  // ignore: recursive_getters
  IntColumn get id => integer().check(id.equals(MemberProfiles.singletonId))();
  TextColumn get name => text()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get photoAsset => text()();
  TextColumn get tierId => text().references(Tiers, #id)();
  IntColumn get totalPoints => integer()();
  IntColumn get pointsToNextTier => integer()();
  IntColumn get notificationsCount => integer()();
  IntColumn get pendingRewardsCount => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
