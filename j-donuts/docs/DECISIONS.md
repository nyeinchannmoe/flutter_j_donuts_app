# Decisions

Short architecture decision records. Each entry covers the context, the
decision and its consequences. Add new entries at the end; replace a
decision by adding a new entry that supersedes the old one.

## ADR-001 Bloc is the only state management

- Context: the brief allows one state approach. Mixing approaches spreads
  rules for lifetimes and testing across the codebase.
- Decision: `bloc`, `flutter_bloc` and `bloc_concurrency` only. Riverpod,
  Provider, GetX and MobX are not allowed.
- Consequences: every screen section has a bloc and a sealed `ViewState`.
  Tests use `bloc_test`.

## ADR-002 One composition root, screens get navigation callbacks

- Context: service locator calls spread through widgets hide dependencies and
  make widget tests depend on global state.
- Decision: `lib/config/dependencies.dart` wires everything through
  `registerCoreServices`, `registerCatalogPipeline` and each feature's
  `register<Feature>Module`. Route builders create blocs and pass navigation
  callbacks into screens. Screens never call `getIt` or `context.go`.
- Consequences: screens are testable with `MockBloc` and plain callbacks.
  Tests use `GetIt.asNewInstance()`.

## ADR-003 drift pinned to 2.34.0 with analyzer 10.2.0

- Context: `drift` and `drift_dev` must use the same version, and `drift_dev`,
  `freezed` and `json_serializable` must agree on one `analyzer` version.
  Newer drift releases need an analyzer the other generators do not support
  yet.
- Decision: pin `drift` to exactly 2.34.0, use `drift_dev` 2.34.0, and add
  `analyzer` 10.2.0 as an explicit dev dependency.
- Consequences: upgrade drift only together with drift_dev and the analyzer,
  after checking freezed and json_serializable support.

## ADR-004 SQLite from sqlite3 build hooks

- Context: `sqlite3` 3.x bundles SQLite through Dart build hooks.
  `sqlite3_flutter_libs` is no longer needed as a direct dependency.
- Decision: no direct `sqlite3_flutter_libs` dependency. `drift_flutter` opens
  the database.
- Consequences: no native setup on any platform.

## ADR-005 build_runner without --delete-conflicting-outputs

- Context: build_runner 2.15 handles conflicting outputs itself and no longer
  needs the flag.
- Decision: the documented command is `dart run build_runner build`.
- Consequences: AGENTS.md, the rules, `tool/verify.sh` and CI use the same
  command.

## ADR-006 The member record belongs to the device

- Context: the seed contains a demo member with points and counters, which
  the user then changes locally. A remote refresh must not reset them.
- Decision: `MemberCatalogImporter` sets `acceptsRemoteUpdates` to false and
  upserts on reseed. Challenge `claimed` flags are excluded from upserts too.
  Display name is not a catalog demo value; registration writes
  `firstName` + optional `lastName` onto `member_profile.name`.
- Consequences: only a seed version bump rewrites the member, and challenge
  progress always survives. Seeded name is empty until registration.

## ADR-007 Shared member and locale code lives in core

- Context: the member profile is shown by home and rewards. The locale is used
  by settings and the app root. Features may not import each other.
- Decision: `lib/core/member` and `lib/core/locale` hold these shared pieces.
- Consequences: no feature-to-feature imports. Core still has no feature
  imports.

## ADR-008 Route access while registering

- Context: after a new number passes OTP, the user is between sign-in and
  being signed in.
- Decision: a `SessionRegistering` session may stay on onboarding, any
  `/auth/` route and welcome. Any other location redirects to the name step.
  The redirect is the pure function `resolveAuthRedirect`, which is unit
  tested.
- Consequences: deep links cannot skip registration, and back navigation
  inside the auth flow still works.

## ADR-009 Fake authentication and validators

- Context: the brief has no backend.
- Decision: local fake auth backed by the `local_users` table. Phone numbers
  must be Myanmar mobile numbers (`9` followed by 7 to 9 digits, with an
  optional `+95`, `95` or `0` prefix; separators are ignored) and are stored as
  E.164. The OTP is 6 digits, the demo code is `123456`, and the OTP screen
  shows it.
- Consequences: a real gateway only needs another implementation of the auth
  repository.

## ADR-010 Duration rule and the retry waiver

- Context: the brief requires durations to come from tokens.
- Decision: presentation code may not create a `Duration` at all. Outside
  presentation, a `Duration` must be a named `const` or `final`. Motion
  durations live in `MotionTokens`, and network and cache durations in their
  constants files. The retry interceptor's computed backoff is the only
  waiver.
- Consequences: the quality gate enforces the rule, and every waiver needs a
  reason.

## ADR-011 Dart 3.12 private named parameters

- Context: Dart 3.12 allows `this._field` in named parameters, which callers
  pass without the underscore.
- Decision: constructors use private named parameters instead of public
  fields or initializer lists.
- Consequences: classes expose no state they do not need to. Callers write
  `SyncCoordinator(remote: ...)`.

## ADR-012 One global snackbar for sync failures

- Context: sync failures are non-fatal and can come from any trigger.
- Decision: `SyncFailureListener` at the app root shows one snackbar per
  failure through the root messenger. Screens keep showing cached data.
- Consequences: screens contain no sync error handling.

## ADR-013 FadeThroughTabStack for the shell

- Context: the default shell stack switches tabs instantly and keeps
  inactive tabs ticking.
- Decision: `FadeThroughTabStack` keeps tab state, fades through on switch
  and wraps inactive tabs in `TickerMode(enabled: false)`.
- Consequences: carousels and pulses stop off-screen.

## ADR-014 Client material stays out of tracked folders

- Context: the brief PDF and screenshots are client property.
- Decision: `design_refs/` and the brief PDF at the repository root are
  git-ignored. The agent could not create `.cursorignore` in this
  environment, so the owner creates it (secrets, keystores and `design_refs/`).
- Consequences: nothing from the brief is committed. Seed images are
  generated placeholders (ADR-025).

## ADR-015 Bundled Outfit font

- Context: `google_fonts` is not allowed and fonts must work offline.
- Decision: bundle Outfit Regular, Medium, SemiBold and Bold (SIL Open Font
  License, `assets/fonts/OFL.txt`) as the closest open geometric sans to the
  design.
- Consequences: each weight must stay under the 160 KiB font budget.

## ADR-016 camelCase JSON

- Context: the seed and the future API need one key style.
- Decision: camelCase keys everywhere, matching Dart field names, so DTOs need
  no `@JsonKey` renames.
- Consequences: the remote API must use the same shape as
  `assets/seed/catalog.json`.

## ADR-017 Upsert rows that others reference, replace lists

- Context: cart items cascade from products. Replacing products would empty
  carts.
- Decision: products, tiers, challenges and the member are upserted. Banners,
  shops and home sections are replaced as whole lists. Products missing from a
  payload are not deleted.
- Consequences: removing a product needs an explicit tombstone in a future
  API version.

## ADR-018 one_member_abstracts disabled

- Context: `very_good_analysis` flags single-method interfaces, but ports such
  as `RemoteDataSource`, `Clock` and `UnitOfWork` are the seams that tests
  fake.
- Decision: disable `one_member_abstracts` in `analysis_options.yaml`, with
  the reason stated there.
- Consequences: interfaces stay named and documented.

## ADR-019 Reference-counted SkeletonScope

- Context: a shimmer controller that keeps running after content has
  loaded wastes frames, and one controller per skeleton multiplies tickers.
- Decision: one `SkeletonScope` at the app root owns the shimmer.
  `SkeletonGroup`s acquire it while mounted, and the controller only runs
  while at least one group is visible. The minimal tier shows static
  skeletons.
- Consequences: no idle tickers once content is shown.

## ADR-020 Explicit drift schema commands

- Context: schema snapshots are a deliberate record of each released
  version and should not change as a side effect of a normal build.
- Decision: `build.yaml` keeps only `store_date_time_values_as_text: false`.
  Schema snapshots, step helpers and test schemas come only from the three
  `drift_dev schema` commands in `DATABASE.md`.
- Consequences: schema changes need those commands, which the new-feature
  checklist lists. On Windows, `schema dump` may need Ctrl+C after it prints
  its output.

## ADR-021 Pruned dependencies

- Context: `collection`, `equatable`, `path` and `path_provider` were added
  early but ended up unused (freezed provides equality and `drift_flutter`
  resolves paths).
- Decision: remove them with `flutter pub remove`.
- Consequences: smaller dependency surface. Add them back only when used.

## ADR-022 AppButton trailing content scales down

- Context: at 320 dp width with text scale 1.3, the button's trailing
  content overflowed by 40 px.
- Decision: the trailing widget sits in `Flexible` with
  `FittedBox(fit: BoxFit.scaleDown)`.
- Consequences: labels never overflow, and the device matrix test covers it.

## ADR-023 No unused motion primitives

- Context: a parallax layer, a particle budget and unused travel tokens were
  defined but no screen used them.
- Decision: remove them. Add them back together with their first use and a
  test.
- Consequences: the motion catalog in the rules matches the code.

## ADR-024 Remote catalog off by default

- Context: there is no API yet, but sync must be exercised.
- Decision: `NoopRemoteDataSource` returns an empty payload unless the app is
  built with `REMOTE_ENABLED=true` and an `API_BASE_URL`. Empty payloads leave
  every section untouched.
- Consequences: all sync triggers, TTL and single-flight logic run in every
  build without network access.

## ADR-025 Generated placeholder seed images

- Context: client photos may not be committed, and the app needs offline
  images.
- Decision: `tool/generate_seed_images.py` draws WebP placeholders under
  stable filenames within the asset budget.
- Consequences: real photos can replace them file by file.
