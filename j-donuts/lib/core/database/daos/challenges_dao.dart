import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/tables/challenges_table.dart';

part 'challenges_dao.g.dart';

@DriftAccessor(tables: [Challenges])
class ChallengesDao extends DatabaseAccessor<AppDatabase>
    with _$ChallengesDaoMixin {
  ChallengesDao(super.attachedDatabase);

  Stream<List<ChallengeRow>> watchChallenges() {
    final query = select(challenges)
      ..orderBy([(row) => OrderingTerm.asc(row.sortOrder)]);
    return query.watch();
  }

  /// Upserts catalog columns only, so the user-owned claimed flag survives.
  Future<void> upsertChallenges(List<ChallengesCompanion> rows) => batch((
    batch,
  ) {
    for (final row in rows) {
      batch.insert(
        challenges,
        row,
        onConflict: DoUpdate(
          (_) => row.copyWith(claimed: const Value.absent()),
        ),
      );
    }
  });
}
