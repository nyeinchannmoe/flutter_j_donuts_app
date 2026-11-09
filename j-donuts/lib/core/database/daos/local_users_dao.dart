import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/tables/local_users_table.dart';

part 'local_users_dao.g.dart';

@DriftAccessor(tables: [LocalUsers])
class LocalUsersDao extends DatabaseAccessor<AppDatabase>
    with _$LocalUsersDaoMixin {
  LocalUsersDao(super.attachedDatabase);

  Future<LocalUserRow?> findByPhone(String phoneE164) {
    final query = select(localUsers)
      ..where((row) => row.phoneE164.equals(phoneE164));
    return query.getSingleOrNull();
  }

  Future<LocalUserRow?> findById(String id) {
    final query = select(localUsers)..where((row) => row.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> insertUser(LocalUsersCompanion user) =>
      into(localUsers).insert(user);
}
