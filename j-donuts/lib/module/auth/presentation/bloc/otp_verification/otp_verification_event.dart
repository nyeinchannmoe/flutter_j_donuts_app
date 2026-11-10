part of 'otp_verification_bloc.dart';

sealed class OtpVerificationEvent {
  const OtpVerificationEvent();
}

final class OtpVerificationStarted extends OtpVerificationEvent {
  const OtpVerificationStarted({
    required this.phoneE164,
    this.existingAccountOnly = false,
  });

  final String phoneE164;
  final bool existingAccountOnly;
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
