# Development

## Requirements

- Flutter 3.44.3 (Dart 3.12.2), stable channel.
- Android Studio or the Android SDK with an emulator, JDK 17.
- Xcode on macOS for iOS builds.
- Python 3 with Pillow, only to regenerate the placeholder seed images.

SQLite is bundled through the `sqlite3` package build hooks, so no native
setup is needed.

## First run

```sh
flutter pub get
dart run build_runner build
flutter gen-l10n
flutter run
```

Generated files (`*.g.dart`, `*.freezed.dart`, `lib/l10n/generated`) are
committed outputs of these commands. Rerun them after changing a Drift
table, a freezed class, a JSON model or an ARB file. While editing, use
`dart run build_runner watch`.

## Configuration

Values come from `--dart-define` and are read only in
`lib/config/app_config.dart`:

| Key | Default | Purpose |
| --- | --- | --- |
| `ENVIRONMENT` | `development` | `development`, `staging` or `production` |
| `REMOTE_ENABLED` | `false` | Turns on remote catalog sync |
| `API_BASE_URL` | empty | Base URL for the remote catalog; required with `REMOTE_ENABLED` |
| `REACHABILITY_HOST` | `example.com` | Host probed to confirm internet access |

Without remote settings the app runs entirely on the bundled seed.

## Demo sign-in

Authentication is fake and local. Enter any valid Myanmar mobile number. The
OTP screen shows the demo code. New numbers go through registration; known
numbers sign in straight away.

## Checks

| Command | What it checks |
| --- | --- |
| `bash tool/verify.sh` | Everything below, in CI order |
| `flutter analyze` | `very_good_analysis` lints, zero issues allowed |
| `flutter test` | Unit, bloc, widget, migration and tool tests |
| `flutter test integration_test` | Sign-in flow on a device or emulator |
| `dart run tool/quality_gate.dart` | File and function length, raw colors, durations, curves, text and layout literals, debug output, task comments |
| `dart run tool/check_asset_budget.dart` | Asset sizes, see `PERFORMANCE_BUDGET.md` |

Quality gate waivers are a single comment on the line before the violation:
`// quality-gate: allow <rule> - <reason>`. Use them only when the rule does
not fit, and always give the reason.

## Tests

- Helpers live in `test/helpers`: `openTestDatabase`, `FakeClock`,
  `catalogRunnerFor`, `seedServiceFor`, `pumpApp` and `DeviceMatrix`.
- Tests build their own `GetIt.asNewInstance()` and never touch the global
  locator.
- Layout tests run across `DeviceMatrix` (320 to 820 wide, text scale 1 and
  1.3) and must not overflow.

## Seed images

```sh
python tool/generate_seed_images.py
```

This redraws every placeholder in `assets/seed/images`. The images are drawn
from primitives, so no client artwork is in the repository.

## Design references

Keep the client brief and screenshots in `design_refs/`, which is
git-ignored. Never copy them into tracked folders.

## Working with agents

Read `AGENTS.md` and `.cursor/rules`. Paste `docs/cursor/USER_RULES.md` into
Cursor Settings → Rules once per machine.
