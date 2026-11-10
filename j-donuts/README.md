# J'Donuts

Customer app for J'Donuts: a fake phone and OTP sign-in, a home feed, product
details and a rewards area. Data is offline-first in an on-device Drift
database seeded from a bundled catalog. Motion goes through a tiered motion
system that adapts to accessibility settings and device performance.

## Requirements

| Tool | Version |
| --- | --- |
| Flutter | 3.44.3, stable channel (recommended and used in CI) |
| Dart | 3.12.2, bundled with Flutter (`sdk: ^3.12.2`) |
| JDK | 17 |
| Android | compileSdk and targetSdk 36, minSdk 24 (Android 7.0) |
| Android NDK | 28.2.13676358, installed by Gradle on the first build |
| Gradle / Android Gradle Plugin / Kotlin | 9.1.0 / 9.0.1 / 2.3.20, through the wrapper |
| iOS | 13.0 or later; Xcode on macOS for iOS builds |
| Python 3 with Pillow | Optional, only to regenerate the placeholder seed images |

Targets are Android and iOS portrait phones from 4.7 to 6.9 inches, with
text scale up to 1.3. Check your toolchain with `flutter --version` and
`flutter doctor`. Package versions are listed in
[docs/STACK.md](docs/STACK.md).

## Quick start

```sh
flutter pub get
dart run build_runner build
flutter gen-l10n
flutter run
```

Generated files (`*.g.dart`, `*.freezed.dart`, `lib/l10n/generated`) must be
regenerated after changing Drift tables, freezed or JSON models, or ARB
files.

## Usage

1. Open the app and go through onboarding.
2. Enter any valid Myanmar mobile number, for example `9123456789` (the
   `+95`, `95` or `0` prefixes are accepted).
3. Enter the demo OTP `123456` (accepted by the fake auth gateway; not shown
   on screen).
4. A new number continues to registration (name and date of birth) and then
   the welcome screen. A number you registered before goes straight to Home.
5. Browse Home (banners, product rails, nearby shops), open a product to
   change the quantity, and open Rewards to see points, tiers and challenges.
6. Pull down on Home to refresh. The app works fully offline: all data comes
   from the on-device database, seeded from `assets/seed/catalog.json`.

Languages are English and Burmese (`my`), selectable in settings.

### Build configuration

Values are passed with `--dart-define`:

| Key | Default | Purpose |
| --- | --- | --- |
| `ENVIRONMENT` | `development` | `development`, `staging` or `production` |
| `REMOTE_ENABLED` | `false` | Turns on remote catalog sync |
| `API_BASE_URL` | empty | Remote catalog base URL, required with `REMOTE_ENABLED` |
| `REACHABILITY_HOST` | `example.com` | Host probed to confirm internet access |

```sh
flutter run --dart-define=ENVIRONMENT=staging
flutter build apk --release --obfuscate --split-debug-info=symbols/android
```

Use `bash tool/build_release.sh` for signed, obfuscated store builds. See
[docs/RELEASE.md](docs/RELEASE.md).

## State management: BLoC, not Riverpod

The app uses `flutter_bloc` with `bloc_concurrency`. Riverpod is not used.

- **Events fit the flows.** Sign-in, OTP entry, cart quantity and pull to
  refresh are user intents. Bloc events such as `PhoneEntrySubmitted` and
  `OtpCodeSubmitted` give each one a type, and the state is a sealed class.
  That makes "what can happen on this screen" explicit and checked by the
  compiler.
- **Concurrency is declared per event.** `droppable` ignores double taps on
  submit, `restartable` swaps database watch streams on retry, and
  `sequential` applies quantity steps and registration edits in order. Riverpod has no single built-in
  equivalent, so each case would need hand-written guards.
- **Offline-first streams map cleanly.** Each screen section watches a Drift
  stream through a use case, and `emit.forEach` turns it into a `ViewState`
  (loading, data, empty, failure). The bloc owns the subscription and cancels
  it on close.
- **Testing is first-class.** `bloc_test` describes behaviour as
  "given these events, expect these states". Widgets are tested with
  `MockBloc` and need no provider container overrides.
- **Clear layering.** Blocs depend only on domain use cases, and
  dependencies are wired by hand in one composition root
  (`lib/config/dependencies.dart`, using `get_it`). Riverpod's providers
  would combine dependency injection and state, which blurs the
  domain/presentation boundary this codebase enforces.

The trade-off is more boilerplate than Riverpod: each bloc has an event,
state and bloc file. Code generation (`freezed`) and one `ViewState` type
shared by all screen sections keep that small. The full record is ADR-001 in
[docs/DECISIONS.md](docs/DECISIONS.md).

## Verify

```sh
bash tool/verify.sh
```

This runs code generation, localization, format check, analyze, tests, the
quality gate and the asset budget. Set `VERIFY_INTEGRATION=1` to also run the
integration test on a connected device.

## Documentation

| Topic | File |
| --- | --- |
| Architecture and layering | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Offline data and sync | [docs/OFFLINE_DATA.md](docs/OFFLINE_DATA.md) |
| Database schema and migrations | [docs/DATABASE.md](docs/DATABASE.md) |
| Motion system | [docs/ANIMATION_GUIDE.md](docs/ANIMATION_GUIDE.md) |
| Performance and asset budgets | [docs/PERFORMANCE_BUDGET.md](docs/PERFORMANCE_BUDGET.md) |
| Local development | [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) |
| Release builds | [docs/RELEASE.md](docs/RELEASE.md) |
| Packages and versions | [docs/STACK.md](docs/STACK.md) |
| Architecture decisions | [docs/DECISIONS.md](docs/DECISIONS.md) |
| Cursor user rules | [docs/cursor/USER_RULES.md](docs/cursor/USER_RULES.md) |

Agents working in this repository start from [AGENTS.md](AGENTS.md) and the
project rules in `.cursor/rules`.
