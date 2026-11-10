import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/config/routes/route_paths.dart';
import 'package:jdonuts/config/routes/route_transitions.dart';
import 'package:jdonuts/core/di/injector.dart';
import 'package:jdonuts/module/auth/domain/entities/auth_flow_mode.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/otp_verification/otp_verification_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/phone_entry/phone_entry_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/welcome/welcome_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/onboarding_entry.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/otp_verification/otp_verification_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/phone_entry/phone_entry_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/registration_date_of_birth/registration_date_of_birth_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/registration_name/registration_name_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/welcome_entry.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/welcome_screen.dart';

/// Onboarding, phone, code, registration and welcome routes.
List<RouteBase> authRoutes() => [
  _onboardingRoute(),
  _phoneRoute(),
  _otpRoute(),
  _registrationRoute(),
  _welcomeRoute(),
];

GoRoute _onboardingRoute() => GoRoute(
  path: RoutePaths.onboarding,
  pageBuilder: (context, state) => RouteTransitions.fadeThrough(
    context,
    state,
    BlocProvider(
      create: (_) => getIt<OnboardingBloc>(),
      child: OnboardingEntry(
        child: OnboardingScreen(
          onGetStarted: () => context.pushNamed<void>(RoutePaths.authPhoneName),
          onLogIn: () => context.pushNamed<void>(
            RoutePaths.authPhoneName,
            queryParameters: {
              RoutePaths.authModeParam: AuthFlowMode.loginQueryValue,
            },
          ),
        ),
      ),
    ),
  ),
);

GoRoute _phoneRoute() => GoRoute(
  path: RoutePaths.authPhone,
  name: RoutePaths.authPhoneName,
  pageBuilder: (context, state) => RouteTransitions.sharedAxis(
    context,
    state,
    _phonePage(context, state),
  ),
);

Widget _phonePage(BuildContext context, GoRouterState state) {
  final mode = AuthFlowMode.fromQuery(
    state.uri.queryParameters[RoutePaths.authModeParam],
  );
  final national = _seededNationalDigits(state);
  return BlocProvider(
    create: (_) => _createPhoneBloc(mode, national),
    child: PhoneEntryScreen(
      initialNationalDigits: national,
      onCodeSent: (phone) => unawaited(_openOtp(context, state, phone)),
      onSwitchToRegister: (phone) {
        context.pushReplacementNamed(
          RoutePaths.authPhoneName,
          queryParameters: {RoutePaths.phoneQueryParam: phone},
        );
      },
    ),
  );
}

String? _seededNationalDigits(GoRouterState state) {
  final seeded = state.uri.queryParameters[RoutePaths.phoneQueryParam];
  if (seeded == null) return null;
  return AuthValidators.nationalDigitsFromE164(seeded);
}

PhoneEntryBloc _createPhoneBloc(AuthFlowMode mode, String? national) {
  final bloc = getIt<PhoneEntryBloc>(param1: mode);
  if (national != null && national.isNotEmpty) {
    bloc.add(PhoneEntrySeeded(national));
  }
  return bloc;
}

Future<void> _openOtp(
  BuildContext context,
  GoRouterState state,
  String phone,
) => context.pushNamed<void>(
  RoutePaths.authOtpName,
  queryParameters: {
    ...state.uri.queryParameters,
    RoutePaths.phoneQueryParam: phone,
  },
);

GoRoute _otpRoute() => GoRoute(
  path: RoutePaths.authOtp,
  name: RoutePaths.authOtpName,
  redirect: (context, state) =>
      state.uri.queryParameters[RoutePaths.phoneQueryParam] == null
      ? RoutePaths.authPhone
      : null,
  pageBuilder: (context, state) => RouteTransitions.sharedAxis(
    context,
    state,
    _otpPage(context, state),
  ),
);

Widget _otpPage(BuildContext context, GoRouterState state) {
  final phone = state.uri.queryParameters[RoutePaths.phoneQueryParam]!;
  final mode = AuthFlowMode.fromQuery(
    state.uri.queryParameters[RoutePaths.authModeParam],
  );
  return BlocProvider(
    create: (_) => getIt<OtpVerificationBloc>()
      ..add(OtpVerificationStarted(phoneE164: phone, mode: mode)),
    child: OtpVerificationScreen(
      phoneE164: phone,
      onNewMemberVerified: () =>
          context.pushReplacement(RoutePaths.authName),
    ),
  );
}

GoRoute _welcomeRoute() => GoRoute(
  path: RoutePaths.welcome,
  pageBuilder: (context, state) => RouteTransitions.fadeThrough(
    context,
    state,
    BlocProvider(
      create: (_) => getIt<WelcomeBloc>(),
      child: WelcomeEntry(
        child: WelcomeScreen(
          onExplore: () async => context.go(RoutePaths.home),
        ),
      ),
    ),
  ),
);

/// Name and date of birth share one RegistrationBloc so the draft
/// survives back navigation between them.
ShellRoute _registrationRoute() => ShellRoute(
  builder: (context, state, child) => BlocProvider(
    create: (_) => getIt<RegistrationBloc>(),
    child: child,
  ),
  routes: [
    GoRoute(
      path: RoutePaths.authName,
      pageBuilder: (context, state) => RouteTransitions.sharedAxis(
        context,
        state,
        RegistrationNameScreen(
          onContinue: () => context.push(RoutePaths.authDob),
        ),
      ),
    ),
    GoRoute(
      path: RoutePaths.authDob,
      pageBuilder: (context, state) => RouteTransitions.sharedAxis(
        context,
        state,
        RegistrationDateOfBirthScreen(
          onRegistered: () => context.go(RoutePaths.welcome),
          clock: getIt(),
        ),
      ),
    ),
  ],
);
