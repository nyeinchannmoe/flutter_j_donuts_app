# Offline data

The local Drift database is the single source of truth. Screens watch DAO
streams through repositories; network results only ever arrive by being
written into the database.

## Bundled seed

- `assets/seed/catalog.json` holds every catalog section: `tiers`, `member`,
  `products`, `banners`, `shops`, `homeSections` and `challenges`. Keys are
  camelCase. Seed images live in `assets/seed/images` as WebP.
- `SeedService.ensureSeeded()` runs during startup. It compares
  `SeedService.seedVersion` with the `seed_version` row in `app_meta`. If they
  match it does nothing.
- Otherwise it loads the bundle and runs every importer plus the version
  write inside one transaction, so a corrupt bundle or a crash rolls back to
  the previous state.
- The cart and local users are not in the catalog and are never touched by a
  reseed.
- Bump `seedVersion` whenever `catalog.json` changes.

## Catalog importers

Each feature owns the importers for its tables
(`CatalogImporter` in `lib/core/database/seed`). An importer declares:

- `sectionKey`: the top-level JSON key it consumes.
- `stage`: `reference` rows (tiers, challenges, products, banners, shops) are
  written before `dependent` rows (home sections, member).
- `acceptsRemoteUpdates`: false for user-owned data such as the member
  record, which is seeded once and then owned by the device.

`CatalogImportRunner` sorts importers by stage and skips sections that are
missing from a payload. The bundled seed and remote refreshes share the same
importers, so both paths have one parser and one write strategy. Products,
challenges, tiers and the member record are upserted, so cart rows keep their
foreign keys. Banners, shops and home sections are replaced as a whole.

## Sync

`SyncCoordinator` is the only entry point for refreshing data.

| Trigger | Source | TTL applies |
| --- | --- | --- |
| `appStart` | `bootstrap()` after seeding | yes |
| `appResume` | `AppLifecycleSyncBinding` | yes |
| `reconnected` | `ConnectivityCubit` when the device comes back online | yes |
| `pullToRefresh` | Home screen refresh gesture | no |

- TTL: `SyncPolicy.defaultCatalogTtl` is 15 minutes, measured from the
  `last_sync_at.catalog` row in `app_meta`. Skipped requests emit `SyncSkipped`.
- Single-flight: while a sync runs, further requests return the same future.
- A successful payload and the new `last_sync_at` are written in one
  transaction.
- Failures emit `SyncFailed` and keep all cached data. The app shows one
  global snackbar for sync failures; screens keep rendering local data.

## Remote source

`RemoteDataSource.fetchCatalog()` returns `Result<CatalogPayload>`.

- `NoopRemoteDataSource` is the default. It returns an empty payload, so every
  section is skipped and the seed stays as is.
- `DioRemoteDataSource` is used when the app is built with
  `--dart-define=REMOTE_ENABLED=true` and a non-empty `API_BASE_URL`. It
  expects the same JSON shape as the seed and maps Dio errors to
  `NetworkFailure` or `TimeoutFailure`. The Dio client retries GET
  requests on timeouts, connection errors and 5xx responses with exponential
  backoff.

## Connectivity

`ConnectivityService` combines `connectivity_plus` with a reachability probe
to `REACHABILITY_HOST`. `ConnectivityCubit` exposes the status to the offline
banner and requests a `reconnected` sync on the transition back online.
