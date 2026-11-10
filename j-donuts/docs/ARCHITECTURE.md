# Architecture

## Layout

```text
lib/
  main.dart, bootstrap.dart, app.dart   entry, startup sequence, root widget
  config/                               AppConfig, composition root, routing
  core/                                 shared infrastructure, no feature imports
  module/<feature>/                     auth, home, product, rewards, notifications
    data/        datasources, models (DTOs), mappers, repositories
    domain/      entities, repository interfaces, use cases
    presentation/ blocs, screens, widgets
    di/          <feature>_injection.dart
  l10n/                                 ARB files and generated localizations
```

`core` holds the database, sync, network, motion, theme, responsive layout,
error and result types, logging, storage, images, locale, member data and
shared widgets. Features may import `core`; `core` never imports a feature.
Features never import each other.

## Layers

- Presentation depends on domain only. Blocs call use cases, never DAOs or DTOs.
- Domain is plain Dart: entities, repository interfaces and use cases that
  return `Result<T>`.
- Data implements the repository interfaces over Drift DAOs. Reads are
  streams from the local database; the UI never waits for the network.
- Errors cross layer boundaries as `AppFailure` inside `Result`, produced by
  `guardResult`. Exceptions do not reach blocs.

## State management

Bloc only (`bloc`, `flutter_bloc`, `bloc_concurrency`). Each screen section has
a bloc whose state is a sealed `ViewState` (loading, data, empty, failure).
Event transformers come from `bloc_concurrency`: `restartable` for watch
events, `droppable` for user commands and `sequential` where order matters.

## Dependency injection

`get_it` is used only in composition code:

- `lib/config/dependencies.dart` is the composition root. It calls
  `registerCoreServices`, `registerCatalogPipeline` with every feature's
  catalog importers, and each feature's `register<Feature>Module` function.
- `lib/core/di` registers infrastructure (database, logger, network, sync,
  motion policy, connectivity).
- `lib/module/<feature>/di` registers repositories, use cases, blocs and the
  feature's `CatalogImporter`s.

Widgets get blocs through `BlocProvider` in route builders. Screens receive
navigation callbacks from the route builders and never call `go_router`
directly, which keeps them testable without a router.

## Routing

`go_router` with a `StatefulShellRoute` for the five tabs. Menu and orders
are placeholder tabs outside the brief's scope. Product detail, section
catalog and notifications sit above the shell. `auth_redirect.dart`
is a pure function of the auth session and the target location;
`RouterRefresh` re-runs it when the session changes. Transitions come from
`route_transitions.dart`, which wraps `MotionTransitions`.

## Startup

`bootstrap()` installs error handlers, builds `AppConfig` from
`--dart-define`, registers dependencies, opens the database, seeds it if
needed, restores the session and locale, and runs the app. If seeding fails,
`StartupErrorApp` shows a retry screen. Connectivity monitoring, the
lifecycle sync binding, the frame budget monitor and an `appStart` sync start
without being awaited, so the first frame never waits for the network.

## Related documents

- [OFFLINE_DATA.md](OFFLINE_DATA.md) for seed and sync.
- [DATABASE.md](DATABASE.md) for schema and migrations.
- [ANIMATION_GUIDE.md](ANIMATION_GUIDE.md) for motion.
- [DECISIONS.md](DECISIONS.md) for the reasoning behind these choices.
