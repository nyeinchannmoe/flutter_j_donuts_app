import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_verification.freezed.dart';

/// Outcome of a correct OTP: returning users go to Home, new users
/// continue registration.
@freezed
abstract class OtpVerification with _$OtpVerification {
  const factory OtpVerification({required bool isRegistered}) =
      _OtpVerification;
}
