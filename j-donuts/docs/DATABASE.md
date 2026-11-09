# Database

Drift over SQLite. `AppDatabase` (`lib/core/database/app_database.dart`)
opens through `drift_flutter` on a background isolate. Tests use
`NativeDatabase.memory` through `test/helpers/test_database.dart`.

## Schema version 3

| Table | Key | Notes |
| --- | --- | --- |
| `app_meta` | `key` | Seed version, `last_sync_at.<scope>`, locale |
| `local_users` | `id` | Fake auth accounts, unique `phone_e164` |
| `tiers` | `id` | Membership tiers from the catalog |
| `member_profiles` | `id` | Single row, `id` checked against `MemberProfiles.singletonId`; references `tiers` |
| `products` | `id` | Unique `code`; nullable `subtitle` (v3) |
| `banners` | `id` | Home carousel; nullable `card_tone` theme key (v2) |
| `home_sections` | `id` | Product rails, unique `kind` |
| `home_section_items` | `section_id, product_id` | Cascades from `home_sections` and `products` |
| `shops` | `id` | Nearby shops |
| `challenges` | `id` | `claimed` is user-owned and survives reseeds |
| `cart_items` | `product_id` | Cascades from `products`, `quantity > 0` |

Migration 1→2 adds nullable `banners.card_tone`. Migration 2→3 adds nullable `products.subtitle`.

Every DAO lives in `lib/core/database/daos`, one per aggregate. DateTimes
are stored as Unix integers (`store_date_time_values_as_text: false` in
`build.yaml`).

## Opening

`beforeOpen` turns on `PRAGMA foreign_keys` and runs `PRAGMA quick_check`. A
failed check throws a `StorageFailure` with code `storage.integrity`, which
startup turns into the retryable error screen.

## Schema snapshots

The current schema is committed as `drift_schemas/drift_schema_v1.json`,
with generated helpers in `lib/core/database/migrations/schema_versions.dart`
and test schemas in `test/core/database/generated`.

Regenerate them with these three commands, run from the project root:

```sh
dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/
dart run drift_dev schema steps drift_schemas/ lib/core/database/migrations/schema_versions.dart
dart run drift_dev schema generate drift_schemas/ test/core/database/generated/
```

On Windows `schema dump` can keep running after it prints `Wrote to ...`.
The file is complete at that point; stop the process with Ctrl+C.

## Migration procedure

1. Change the tables, bump `DatabaseSchema.version` and run
   `dart run build_runner build`.
2. Run the three schema commands above. A new `drift_schema_vN.json` appears.
3. In `lib/core/database/migrations/database_migration.dart`, add a case for
   the previous version to `_runStep` using the generated `stepByStep` helper.
   Upgrades run one version at a time in one transaction with foreign keys
   off; an unknown version throws `storage.unsupportedUpgrade`.
4. Add a `SchemaVerifier` test for the new step in
   `test/core/database/migration_test.dart`, including data that must survive.
5. If the table holds catalog data, extend `assets/seed/catalog.json` and the
   importer, and bump `SeedService.seedVersion`.
6. Update the table above and run `tool/verify.sh`.
