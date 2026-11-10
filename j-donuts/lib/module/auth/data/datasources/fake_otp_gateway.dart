/// Waits for [duration]; injectable so tests run instantly.
typedef LatencySimulator = Future<void> Function(Duration duration);

Future<void> _realLatency(Duration duration) => Future<void>.delayed(duration);

/// Stand-in for an SMS OTP provider.
class FakeOtpGateway {
  const FakeOtpGateway({this._latency = _realLatency});

  /// The only code this demo accepts. Documented in the project README.
  static const String demoCode = '123456';
  static const Duration simulatedLatency = Duration(seconds: 1);

  final LatencySimulator _latency;

  Future<void> simulateNetwork() => _latency(simulatedLatency);

  Future<void> sendCode(String phoneE164) => simulateNetwork();

  Future<bool> verifyCode(String code) async {
    await simulateNetwork();
    return code == demoCode;
  }
}
