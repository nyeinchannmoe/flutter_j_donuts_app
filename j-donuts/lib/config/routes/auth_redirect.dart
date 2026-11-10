import 'package:jdonuts/config/routes/route_paths.dart';
import 'package:jdonuts/module/auth/domain/entities/session.dart';

/// Where [session] may be at [location]: null to stay, or the path to go.
///
/// Pure so every status and location combination is unit-tested.
String? resolveAuthRedirect({
  required Session session,
  required String location,
}) {
  final isLaunch = location == RoutePaths.launch;
  final isOnboarding = location == RoutePaths.onboarding;
  final isAuth = location.startsWith('${RoutePaths.authPrefix}/');
  return switch (session) {
    SessionUnknown() => isLaunch ? null : RoutePaths.launch,
    SessionUnauthenticated() =>
      isOnboarding ||
              location == RoutePaths.authPhone ||
              location == RoutePaths.authOtp
          ? null
          : RoutePaths.onboarding,
    SessionRegistering() =>
      isOnboarding || isAuth ? null : RoutePaths.authName,
    SessionAuthenticated(:final isNewlyRegistered) =>
      isLaunch || isOnboarding || isAuth
          ? (isNewlyRegistered ? RoutePaths.welcome : RoutePaths.home)
          : null,
  };
}
