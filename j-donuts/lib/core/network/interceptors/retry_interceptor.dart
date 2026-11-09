import 'dart:math';

import 'package:dio/dio.dart';
import 'package:jdonuts/core/network/network_constants.dart';

/// Waits for [duration]; injectable so tests do not sleep.
typedef RetryDelay = Future<void> Function(Duration duration);

Future<void> _realDelay(Duration duration) => Future<void>.delayed(duration);

/// Retries idempotent GET requests on transient failures with exponential
/// backoff and jitter, up to [maxAttempts] retries.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this._dio,
    this.maxAttempts = NetworkConstants.maxRetryAttempts,
    this.baseDelay = NetworkConstants.retryBaseDelay,
    this.maxDelay = NetworkConstants.retryMaxDelay,
    Random? random,
    this._delay = _realDelay,
  }) : _random = random ?? Random();

  static const String attemptKey = 'retry_attempt';
  static const int _firstServerErrorStatus = 500;

  final Dio _dio;
  final int maxAttempts;
  final Duration baseDelay;
  final Duration maxDelay;
  final Random _random;
  final RetryDelay _delay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[attemptKey] as int?) ?? 0;
    if (!_shouldRetry(err) || attempt >= maxAttempts) {
      handler.next(err);
      return;
    }
    await _delay(backoffFor(attempt));
    options.extra[attemptKey] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Exponential backoff capped at [maxDelay] with symmetric jitter.
  Duration backoffFor(int attempt) {
    final exponential = baseDelay.inMilliseconds * pow(2, attempt);
    final capped = min(exponential, maxDelay.inMilliseconds.toDouble());
    final jitterSpan = capped * NetworkConstants.retryJitterRatio;
    final jitter = (_random.nextDouble() * 2 - 1) * jitterSpan;
    // quality-gate: allow duration - computed backoff, not a tunable value
    return Duration(milliseconds: (capped + jitter).round());
  }

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.method.toUpperCase() != 'GET') return false;
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse =>
        (err.response?.statusCode ?? 0) >= _firstServerErrorStatus,
      _ => false,
    };
  }
}
