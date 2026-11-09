# AGENTS.md

Operating manual for any coding agent working in this repository. The detailed rules live in `.cursor/rules/`; this file never contradicts them.

## Purpose
J'Donuts customer app (Madivizion Senior Flutter code test): fake login and registration with real validation, an offline-first Home and Product detail backed by Drift, and an animated Rewards screen. Android and iOS, portrait phones, no backend.

## Architecture in one screen
- `lib/main.dart` calls `bootstrap()`. `lib/bootstrap.dart` installs error handlers, registers dependencies, opens and seeds the database, restores the session and runs `JDonutsApp` (`lib/app.dart`).
- `lib/config`: environment (`AppConfig`), the dependency aggregator (`dependencies.dart`) and routing (`go_router`, pure `resolveAuthRedirect`, transitions, five-tab shell).
- `lib/core`: shared kernel. Result and AppFailure, DI, logging, Drift database (tables, DAOs, migrations, seed), network (Dio, disabled by default), sync coordinator, connectivity, secure session storage, images, theme tokens, responsive metrics, motion system, view state, shared widgets, locale, and the shared member record.
- `lib/module/{auth,home,product,rewards}`: each with `domain` (pure Dart entities, repository interfaces, use cases), `data` (DTOs, mappers, importers, repository implementations) and `presentation` (Blocs, screens, widgets), plus `di/<feature>_injection.dart`.
- Data flow: bundled JSON or remote payload, then importers inside one Drift transaction, then DAO watch streams, then repositories returning `Result`, then use cases, then Blocs emitting `ViewState`, then widgets.
- State: Bloc only. DI: get_it, referenced only in the composition root. UI reads only the local database.

## Commands
- Install: `flutter pub get`
- Code generation: `dart run build_runner build` (build_runner 2.15 always replaces conflicting outputs)
- Localization: `flutter gen-l10n`
- Analyze: `flutter analyze`
- Test: `flutter test`
- Integration test (device or emulator running): `flutter test integration_test`
- Quality gate: `dart run tool/quality_gate.dart`
- Asset budget: `dart run tool/check_asset_budget.dart`
- Everything in order: `bash tool/verify.sh`
- Release builds: `bash tool/build_release.sh`

## Definition of done
1. Code generation and gen-l10n succeed.
2. `flutter analyze` reports zero issues.
3. `flutter test` passes; the integration test passes when a device is available.
4. The quality gate and asset budget pass.
5. Docs in `docs/`, the rules in `.cursor/rules/` and this file agree with the code.

## Forbidden
- Any git command or git-based tool, and any access to `.git`.
- Printing code, diffs or file contents in chat. The final message is a summary of at most 20 lines.
- Packages: riverpod, provider (directly), get, mobx, flutter_screenutil, google_fonts, 3D engines, Lottie or Rive without an ADR.
- TODO, FIXME, commented-out code, dead code, print or debugPrint, hard-coded colors, strings or spacing in widgets.
- Editing generated files by hand. Copying client designs into tracked folders.

## Pointers
- Rules: `.cursor/rules/*.mdc` (start with 00, 10 and 90).
- Docs: `docs/ARCHITECTURE.md`, `docs/OFFLINE_DATA.md`, `docs/DATABASE.md`, `docs/ANIMATION_GUIDE.md`, `docs/PERFORMANCE_BUDGET.md`, `docs/DEVELOPMENT.md`, `docs/RELEASE.md`, `docs/STACK.md`, `docs/DECISIONS.md`.
- Personal Cursor user rules template: `docs/cursor/USER_RULES.md`.
