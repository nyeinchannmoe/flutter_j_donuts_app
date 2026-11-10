import 'package:get_it/get_it.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/module/auth/data/datasources/fake_otp_gateway.dart';
import 'package:jdonuts/module/auth/data/repositories/fake_auth_repository.dart';
import 'package:jdonuts/module/auth/domain/repositories/auth_repository.dart';
import 'package:jdonuts/module/auth/domain/usecases/register_user.dart';
import 'package:jdonuts/module/auth/domain/usecases/request_otp.dart';
import 'package:jdonuts/module/auth/domain/usecases/restore_session.dart';
import 'package:jdonuts/module/auth/domain/usecases/save_registration_name.dart';
import 'package:jdonuts/module/auth/domain/usecases/sign_out.dart';
import 'package:jdonuts/module/auth/domain/usecases/verify_otp.dart';
import 'package:jdonuts/module/auth/domain/usecases/watch_session.dart';
import 'package:jdonuts/module/auth/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/otp_verification/otp_verification_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/phone_entry/phone_entry_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:jdonuts/module/auth/presentation/bloc/welcome/welcome_bloc.dart';

void registerAuthModule(GetIt locator) {
  _registerData(locator);
  _registerUseCases(locator);
  _registerBlocs(locator);
}

void _registerData(GetIt locator) {
  locator
    ..registerLazySingleton(FakeOtpGateway.new)
    ..registerLazySingleton<AuthRepository>(
      () => FakeAuthRepository(
        usersDao: locator<AppDatabase>().localUsersDao,
        sessionStore: locator(),
        otpGateway: locator(),
        logger: locator(),
        clock: locator(),
      ),
    );
}

void _registerUseCases(GetIt locator) {
  locator
    ..registerFactory(() => WatchSession(locator()))
    ..registerFactory(() => RestoreSession(locator()))
    ..registerFactory(() => RequestOtp(locator()))
    ..registerFactory(() => VerifyOtp(locator()))
    ..registerFactory(() => SaveRegistrationName(locator()))
    ..registerFactory(() => RegisterUser(locator(), clock: locator()))
    ..registerFactory(() => SignOut(locator()));
}

void _registerBlocs(GetIt locator) {
  locator
    ..registerFactory(OnboardingBloc.new)
    ..registerFactory(WelcomeBloc.new)
    ..registerFactory(() => PhoneEntryBloc(requestOtp: locator()))
    ..registerFactory(
      () => OtpVerificationBloc(
        verifyOtp: locator(),
        requestOtp: locator(),
        clock: locator(),
        ticker: locator(),
      ),
    )
    ..registerFactory(
      () => RegistrationBloc(
        saveRegistrationName: locator(),
        registerUser: locator(),
        clock: locator(),
      ),
    );
}
