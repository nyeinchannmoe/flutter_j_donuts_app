# Stack

Toolchain: Flutter 3.44.3, Dart 3.12.2. Versions below are the ones
resolved in `pubspec.lock`. Add packages with `flutter pub add` and update
this table in the same change.

## Runtime dependencies

| Package | Version | Purpose |
| --- | --- | --- |
| `bloc` | 9.2.1 | State management core |
| `flutter_bloc` | 9.1.1 | Bloc widgets |
| `bloc_concurrency` | 0.3.0 | Event transformers |
| `go_router` | 18.1.3 | Declarative routing and the tab shell |
| `get_it` | 9.3.0 | Service locator, used only in composition code |
| `drift` | 2.34.0 (pinned) | SQLite ORM, see ADR-003 |
| `drift_flutter` | 0.3.1 | Opens Drift on a background isolate |
| `dio` | 5.11.1 | HTTP client for the remote catalog |
| `connectivity_plus` | 7.3.2 | Network interface changes |
| `cached_network_image` | 4.0.3 | Network images with placeholders |
| `flutter_cache_manager` | 3.5.0 | Shared image cache with size limits |
| `flutter_secure_storage` | 11.2.0 | Session storage |
| `freezed_annotation` | 3.1.0 | Immutable entities and states |
| `json_annotation` | 4.12.0 | DTO serialization |
| `animations` | 3.0.0 | Shared-axis and fade-through transitions |
| `intl` | 0.20.2 | Localization and number and date formatting |
| `logger` | 2.8.0 | Logging behind `AppLogger` |
| `meta` | 1.18.0 | `@immutable` and `@visibleForTesting` in plain Dart files |
| `flutter_localizations` | SDK | Material and Cupertino localizations |

Transitive native pieces: `sqlite3` 3.5.2 bundles SQLite through build hooks,
so `sqlite3_flutter_libs` is not a direct dependency.

## Development dependencies

| Package | Version | Purpose |
| --- | --- | --- |
| `build_runner` | 2.15.1 | Code generation runner |
| `drift_dev` | 2.34.0 | Drift generator and schema tools |
| `freezed` | 3.2.5 | Freezed generator |
| `json_serializable` | 6.15.2 | JSON generator |
| `analyzer` | 10.2.0 | Pinned to the range `drift_dev` supports, see ADR-003 |
| `very_good_analysis` | 10.3.0 | Lint set |
| `bloc_test` | 10.0.0 | Bloc tests |
| `mocktail` | 1.0.5 | Mocks without code generation |
| `flutter_test`, `integration_test` | SDK | Widget and integration tests |

## Not allowed

`riverpod`, `provider`, `get`, `mobx`, `flutter_screenutil`, `google_fonts`,
3D engines, Lottie and Rive. Fonts are bundled (Outfit, SIL Open Font
License in `assets/fonts/OFL.txt`).
