import 'package:go_router/go_router.dart';
import 'package:jdonuts/config/routes/app_shell_scaffold.dart';
import 'package:jdonuts/config/routes/auth_redirect.dart';
import 'package:jdonuts/config/routes/auth_routes.dart';
import 'package:jdonuts/config/routes/route_paths.dart';
import 'package:jdonuts/config/routes/route_transitions.dart';
import 'package:jdonuts/config/routes/router_refresh.dart';
import 'package:jdonuts/config/routes/shell_routes.dart';
import 'package:jdonuts/core/motion/transitions/fade_through_tab_stack.dart';
import 'package:jdonuts/core/widgets/scaffold/launch_screen.dart';
import 'package:jdonuts/module/auth/presentation/bloc/session/session_bloc.dart';

/// Builds the app router. Redirects follow the SessionBloc state.
GoRouter buildRouter({required SessionBloc sessionBloc}) => GoRouter(
  initialLocation: RoutePaths.launch,
  refreshListenable: RouterRefreshStream(sessionBloc.stream),
  redirect: (context, state) => resolveAuthRedirect(
    session: sessionBloc.state,
    location: state.matchedLocation,
  ),
  routes: [
    GoRoute(
      path: RoutePaths.launch,
      pageBuilder: (context, state) =>
          RouteTransitions.fadeThrough(context, state, const LaunchScreen()),
    ),
    ...authRoutes(),
    StatefulShellRoute(
      builder: (context, state, navigationShell) =>
          AppShellScaffold(navigationShell: navigationShell),
      navigatorContainerBuilder: (context, navigationShell, children) =>
          FadeThroughTabStack(
            currentIndex: navigationShell.currentIndex,
            children: children,
          ),
      branches: shellBranches(),
    ),
    productRoute(),
  ],
);
