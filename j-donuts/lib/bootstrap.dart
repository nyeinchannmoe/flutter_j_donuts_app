import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:jdonuts/app.dart';
import 'package:jdonuts/config/app_config.dart';
import 'package:jdonuts/config/dependencies.dart';
import 'package:jdonuts/config/routes/routes.dart';
import 'package:jdonuts/core/connectivity/connectivity_cubit.dart';
import 'package:jdonuts/core/connectivity/connectivity_service.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/seed/seed_service.dart';
import 'package:jdonuts/core/di/injector.dart';
import 'package:jdonuts/core/images/app_image_cache_manager.dart';
import 'package:jdonuts/core/locale/locale_cubit.dart';
import 'package:jdonuts/core/locale/locale_preference_store.dart';
import 'package:jdonuts/core/logging/app_bloc_observer.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/motion/motion_policy.dart';
import 'package:jdonuts/core/sync/app_lifecycle_sync_binding.dart';
import 'package:jdonuts/core/sync/sync_coordinator.dart';
import 'package:jdonuts/core/sync/sync_policy.dart';
import 'package:jdonuts/core/widgets/scaffold/startup_error_app.dart';
import 'package:jdonuts/core/widgets/state_views/build_error_view.dart';
import 'package:jdonuts/module/auth/domain/entities/session.dart';
import 'package:jdonuts/module/auth/domain/usecases/restore_session.dart';
import 'package:jdonuts/module/auth/presentation/bloc/session/session_bloc.dart';

/// Installs error handling, wires dependencies, prepares local data and
/// runs the app. Nothing here touches the network before the first frame.
Future<void> bootstrap() async {
  final logger = AppLogger();
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      _installErrorHandlers(logger);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      if (!kReleaseMode) Bloc.observer = AppBlocObserver(logger);
      configureDependencies(
        getIt,
        config: AppConfig.fromEnvironment(),
        logger: logger,
        database: AppDatabase.open(),
        bundle: rootBundle,
      );
      await _start();
    },
    (error, stackTrace) => logger.error(
      'Uncaught zone error',
      error: error,
      stackTrace: stackTrace,
    ),
  );
}

void _installErrorHandlers(AppLogger logger) {
  FlutterError.onError = (details) {
    logger.error(
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
    if (kDebugMode) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error(
      'Uncaught platform error',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };
  if (!kDebugMode) ErrorWidget.builder = (_) => const BuildErrorView();
}

/// Seeds, restores the session and runs the app, or shows a retryable
/// startup error when local data cannot be prepared.
Future<void> _start() async {
  final seeded = await getIt<SeedService>().ensureSeeded();
  if (!seeded.isOk) {
    runApp(const StartupErrorApp(onRetry: _start));
    return;
  }
  final session = await getIt<RestoreSession>()();
  final locale = await getIt<LocalePreferenceStore>().read();
  _startBackgroundServices();
  runApp(
    JDonutsApp(
      dependencies: _appDependencies(
        session: session.valueOrNull ?? const Session.unauthenticated(),
        languageCode: locale.valueOrNull,
      ),
    ),
  );
}

void _startBackgroundServices() {
  final sync = getIt<SyncCoordinator>();
  unawaited(getIt<ConnectivityService>().start());
  getIt<AppLifecycleSyncBinding>().attach();
  getIt<MotionPolicy>().startMonitoring();
  unawaited(sync.requestSync(SyncTrigger.appStart));
}

AppDependencies _appDependencies({
  required Session session,
  required String? languageCode,
}) {
  final sessionBloc = SessionBloc(
    watchSession: getIt(),
    signOut: getIt(),
    initial: session,
  )..add(const SessionStarted());
  return AppDependencies(
    sessionBloc: sessionBloc,
    connectivityCubit: getIt<ConnectivityCubit>(),
    localeCubit: LocaleCubit(
      store: getIt(),
      initial: languageCode == null ? null : Locale(languageCode),
    ),
    router: buildRouter(sessionBloc: sessionBloc),
    motionPolicy: getIt(),
    imageCacheManager: getIt<AppImageCacheManager>(),
    syncStatus: getIt<SyncCoordinator>().status,
  );
}
