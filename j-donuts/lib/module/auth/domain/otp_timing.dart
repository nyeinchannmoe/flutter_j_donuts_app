/// Timing and attempt limits for the verification-code step.
abstract final class OtpTiming {
  static const Duration resendWindow = Duration(minutes: 5);
  static const Duration tickInterval = Duration(seconds: 1);
  static const int maxFailedAttempts = 3;
}
