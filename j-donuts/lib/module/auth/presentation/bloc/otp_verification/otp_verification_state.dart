part of 'otp_verification_bloc.dart';

@freezed
abstract class OtpVerificationState with _$OtpVerificationState {
  const factory OtpVerificationState({
    required DateTime resendAvailableAt,
    @Default('') String code,
    @Default(0) int failedAttempts,
    @Default(false) bool locked,
    @Default(false) bool verifying,
    bool? verifiedIsRegistered,
    AppFailure? failure,
    @Default(Duration.zero) Duration remaining,
    @Default(0) int shakeEpoch,
  }) = _OtpVerificationState;
}

extension OtpVerificationStateX on OtpVerificationState {
  bool get canResend => remaining == Duration.zero;

  bool get isVerified => verifiedIsRegistered != null;
}
