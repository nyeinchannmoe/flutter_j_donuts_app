import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:jdonuts/core/database/daos/app_meta_dao.dart';
import 'package:jdonuts/core/database/daos/cart_dao.dart';
import 'package:jdonuts/core/database/daos/challenges_dao.dart';
import 'package:jdonuts/core/database/daos/home_dao.dart';
import 'package:jdonuts/core/database/daos/local_users_dao.dart';
import 'package:jdonuts/core/database/daos/member_dao.dart';
import 'package:jdonuts/core/database/daos/products_dao.dart';
import 'package:jdonuts/core/database/migrations/database_migration.dart';
import 'package:jdonuts/core/database/tables/app_meta_table.dart';
import 'package:jdonuts/core/database/tables/banners_table.dart';
import 'package:jdonuts/core/database/tables/cart_items_table.dart';
import 'package:jdonuts/core/database/tables/challenges_table.dart';
import 'package:jdonuts/core/database/tables/home_section_items_table.dart';
import 'package:jdonuts/core/database/tables/home_sections_table.dart';
import 'package:jdonuts/core/database/tables/local_users_table.dart';
import 'package:jdonuts/core/database/tables/member_profile_table.dart';
import 'package:jdonuts/core/database/tables/products_table.dart';
import 'package:jdonuts/core/database/tables/shops_table.dart';
import 'package:jdonuts/core/database/tables/tiers_table.dart';

part 'app_database.g.dart';

/// Versioning constants for the local database.
abstract final class DatabaseSchema {
  /// Bump together with a new drift_schemas dump and migration step.
  static const int version = 3;
  static const String fileName = 'jdonuts';
}

@DriftDatabase(
  tables: [
    AppMeta,
    LocalUsers,
    Tiers,
    MemberProfiles,
    Products,
    Banners,
    HomeSections,
    HomeSectionItems,
    Shops,
    Challenges,
    CartItems,
  ],
  daos: [
    AppMetaDao,
    LocalUsersDao,
    MemberDao,
    ProductsDao,
    HomeDao,
    ChallengesDao,
    CartDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-device database on a background isolate.
  factory AppDatabase.open() =>
      AppDatabase(driftDatabase(name: DatabaseSchema.fileName));

  @override
  int get schemaVersion => DatabaseSchema.version;

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);
}
