import 'package:drift/drift.dart';

/// Reward challenges. [claimed] is user state and survives reseeding.
@DataClassName('ChallengeRow')
@TableIndex(name: 'challenges_sort_order_idx', columns: {#sortOrder})
class Challenges extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get kind => text()();
  IntColumn get progressCurrent => integer()();
  IntColumn get progressTarget => integer()();
  IntColumn get rewardPoints => integer()();
  TextColumn get imageAsset => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get claimed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
