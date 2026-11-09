import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/connectivity/connectivity_cubit.dart';
import 'package:jdonuts/core/images/app_image_cache_manager.dart';
import 'package:jdonuts/core/locale/locale_cubit.dart';
import 'package:jdonuts/core/motion/motion_policy.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/sync/sync_status.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/core/widgets/offline_banner.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_scope.dart';
import 'package:jdonuts/core/widgets/sync_failure_listener.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/presentation/bloc/session/session_bloc.dart';

/// Everything the root widget needs, created in bootstrap.
class AppDependencies {
  const AppDependencies({
    required this.sessionBloc,
    required this.connectivityCubit,
    required this.localeCubit,
    required this.router,
    required this.motionPolicy,
    required this.imageCacheManager,
    required this.syncStatus,
  });

  final SessionBloc sessionBloc;
  final ConnectivityCubit connectivityCubit;
  final LocaleCubit localeCubit;
  final GoRouter router;
  final MotionPolicy motionPolicy;
  final BaseCacheManager imageCacheManager;
  final Stream<SyncStatus> syncStatus;
}

class JDonutsApp extends StatefulWidget {
  const JDonutsApp({required this.dependencies, super.key});

  final AppDependencies dependencies;

  @override
  State<JDonutsApp> createState() => _JDonutsAppState();
}

class _JDonutsAppState extends State<JDonutsApp> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late final ThemeData _theme = AppTheme.light();

  @override
  Widget build(BuildContext context) {
    final deps = widget.dependencies;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: deps.sessionBloc),
        BlocProvider.value(value: deps.connectivityCubit),
        BlocProvider.value(value: deps.localeCubit),
      ],
      child: BlocBuilder<LocaleCubit, Locale?>(
        builder: (context, locale) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: _messengerKey,
          theme: _theme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: deps.router,
          builder: (context, child) => _AppChrome(
            dependencies: deps,
            messengerKey: _messengerKey,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

/// App-wide layers between MaterialApp and the router's navigator.
class _AppChrome extends StatelessWidget {
  const _AppChrome({
    required this.dependencies,
    required this.messengerKey,
    required this.child,
  });

  final AppDependencies dependencies;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  Widget build(BuildContext context) => MotionScope(
    policy: dependencies.motionPolicy,
    child: ImageCacheScope(
      cacheManager: dependencies.imageCacheManager,
      child: SkeletonScope(
        child: SyncFailureListener(
          status: dependencies.syncStatus,
          messengerKey: messengerKey,
          child: OfflineBannerHost(child: child),
        ),
      ),
    ),
  );
}
