/// Network timing and retry constants.
abstract final class NetworkConstants {
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String apiVersionPath = '/v1/';
  static const String catalogPath = 'catalog';

  static const int maxRetryAttempts = 3;
  static const Duration retryBaseDelay = Duration(milliseconds: 400);
  static const Duration retryMaxDelay = Duration(seconds: 4);

  /// Fraction of the computed backoff that is randomised to avoid
  /// synchronized retries from many clients.
  static const double retryJitterRatio = 0.25;

  static const Set<String> redactedHeaders = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-api-key',
  };
  static const String redactedValue = '<redacted>';
}
