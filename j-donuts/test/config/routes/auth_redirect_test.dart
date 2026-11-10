import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/config/routes/auth_redirect.dart';
import 'package:jdonuts/config/routes/route_paths.dart';
import 'package:jdonuts/module/auth/domain/entities/session.dart';

const String _phone = '+959123456789';

const List<String> _authSteps = [
  RoutePaths.authPhone,
  RoutePaths.authOtp,
  RoutePaths.authName,
  RoutePaths.authDob,
];

const List<String> _appLocations = [
  RoutePaths.home,
  RoutePaths.explore,
  RoutePaths.rewards,
  RoutePaths.orders,
  RoutePaths.settings,
  RoutePaths.notifications,
  '/product/p_coconut',
  '/section/seasonal',
];

String? _redirect(Session session, String location) =>
    resolveAuthRedirect(session: session, location: location);

void main() {
  group('unknown session', () {
    test('stays on launch', () {
      expect(_redirect(const Session.unknown(), RoutePaths.launch), isNull);
    });

    test('sends every other location to launch', () {
      for (final location in [
        RoutePaths.onboarding,
        RoutePaths.welcome,
        ..._authSteps,
        ..._appLocations,
      ]) {
        expect(
          _redirect(const Session.unknown(), location),
          RoutePaths.launch,
          reason: location,
        );
      }
    });
  });

  group('unauthenticated session', () {
    const session = Session.unauthenticated();

    test('may use onboarding, phone and code steps', () {
      for (final location in [
        RoutePaths.onboarding,
        RoutePaths.authPhone,
        RoutePaths.authOtp,
      ]) {
        expect(_redirect(session, location), isNull, reason: location);
      }
    });

    test('is sent to onboarding from registration and the app', () {
      for (final location in [
        RoutePaths.launch,
        RoutePaths.authName,
        RoutePaths.authDob,
        RoutePaths.welcome,
        ..._appLocations,
      ]) {
        expect(
          _redirect(session, location),
          RoutePaths.onboarding,
          reason: location,
        );
      }
    });
  });

  group('registering session', () {
    const session = Session.registering(phoneE164: _phone);

    test('may use onboarding, every auth step and welcome', () {
      for (final location in [
        RoutePaths.onboarding,
        RoutePaths.welcome,
        ..._authSteps,
      ]) {
        expect(_redirect(session, location), isNull, reason: location);
      }
    });

    test('is sent to the name step from launch and the app', () {
      for (final location in [RoutePaths.launch, ..._appLocations]) {
        expect(
          _redirect(session, location),
          RoutePaths.authName,
          reason: location,
        );
      }
    });
  });

  group('authenticated session', () {
    const returning = Session.authenticated(userId: 'u_1', phoneE164: _phone);
    const fresh = Session.authenticated(
      userId: 'u_1',
      phoneE164: _phone,
      isNewlyRegistered: true,
    );

    test('may use every app location and welcome', () {
      for (final location in [RoutePaths.welcome, ..._appLocations]) {
        expect(_redirect(returning, location), isNull, reason: location);
      }
    });

    test('a returning member is sent home from launch and auth', () {
      for (final location in [
        RoutePaths.launch,
        RoutePaths.onboarding,
        ..._authSteps,
      ]) {
        expect(
          _redirect(returning, location),
          RoutePaths.home,
          reason: location,
        );
      }
    });

    test('a new member is sent to welcome from launch and auth', () {
      for (final location in [
        RoutePaths.launch,
        RoutePaths.onboarding,
        ..._authSteps,
      ]) {
        expect(
          _redirect(fresh, location),
          RoutePaths.welcome,
          reason: location,
        );
      }
    });
  });
}
