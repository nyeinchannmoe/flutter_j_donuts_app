part of 'otp_verification_bloc.dart';

sealed class OtpVerificationEvent {
  const OtpVerificationEvent();
}

final class OtpVerificationStarted extends OtpVerificationEvent {
  const OtpVerificationStarted({
    required this.phoneE164,
    this.mode = AuthFlowMode.register,
  });

  final String phoneE164;
  final AuthFlowMode mode;
}

final class OtpCodeChanged extends OtpVerificationEvent {
  const OtpCodeChanged(this.code);

  final String code;
}

final class OtpCountdownTicked extends OtpVerificationEvent {
  const OtpCountdownTicked();
}

final class OtpResendRequested extends OtpVerificationEvent {
  const OtpResendRequested();
}
