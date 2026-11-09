part of 'otp_verification_bloc.dart';

@freezed
sealed class OtpVerificationState with _$OtpVerificationState {
  const factory OtpVerificationState.idle() = OtpIdle;

  const factory OtpVerificationState.verifying() = OtpVerifying;

  /// New users continue to the name step; returning users are moved to
  /// Home by the router once the session becomes authenticated.
  const factory OtpVerificationState.verified({required bool isRegistered}) =
      OtpVerified;

  /// [failedAttempts] counts consecutive wrong codes, so every rejection is
  /// a distinct state even when the failure is the same.
  const factory OtpVerificationState.rejected({
    required AppFailure failure,
    required int failedAttempts,
  }) = OtpRejected;
}
