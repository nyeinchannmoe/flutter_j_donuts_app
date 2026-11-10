part of 'otp_verification_bloc.dart';

sealed class OtpVerificationEvent {
  const OtpVerificationEvent();
}

final class OtpCodeSubmitted extends OtpVerificationEvent {
  const OtpCodeSubmitted({
    required this.phoneE164,
    required this.code,
    this.existingAccountOnly = false,
  });

  final String phoneE164;
  final String code;
  final bool existingAccountOnly;
}
