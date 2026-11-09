import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/network/interceptors/retry_interceptor.dart';
import 'package:jdonuts/core/network/network_constants.dart';

/// Fails the first [failures] requests with [error], then answers 200.
class _FlakyAdapter implements HttpClientAdapter {
  _FlakyAdapter({required this.failures, this.error = _connectionError});

  final int failures;
  final DioException Function(RequestOptions options) error;
  int calls = 0;

  static DioException _connectionError(RequestOptions options) =>
      DioException.connectionError(requestOptions: options, reason: 'offline');

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (calls <= failures) throw error(options);
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(_FlakyAdapter adapter, {List<Duration>? delays}) {
  final dio = Dio()..httpClientAdapter = adapter;
  dio.interceptors.add(
    RetryInterceptor(
      dio: dio,
      random: Random(1),
      delay: (duration) async => delays?.add(duration),
    ),
  );
  return dio;
}

void main() {
  group('RetryInterceptor', () {
    test('retries GET connection errors until one succeeds', () async {
      final adapter = _FlakyAdapter(failures: 2);
      final delays = <Duration>[];

      final response = await _dioWith(
        adapter,
        delays: delays,
      ).get<Object?>('https://api.test/v1/catalog');

      expect(response.statusCode, 200);
      expect(adapter.calls, 3);
      expect(delays[1], greaterThan(delays[0]));
    });

    test('gives up after the maximum number of retries', () async {
      final adapter = _FlakyAdapter(failures: 100);

      await expectLater(
        _dioWith(adapter).get<Object?>('https://api.test/v1/catalog'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, NetworkConstants.maxRetryAttempts + 1);
    });

    test('never retries non-GET requests', () async {
      final adapter = _FlakyAdapter(failures: 1);

      await expectLater(
        _dioWith(adapter).post<Object?>('https://api.test/v1/catalog'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
    });

    test('does not retry client errors', () async {
      final adapter = _FlakyAdapter(
        failures: 1,
        error: (options) => DioException.badResponse(
          statusCode: 404,
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 404),
        ),
      );

      await expectLater(
        _dioWith(adapter).get<Object?>('https://api.test/v1/catalog'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 1);
    });

    test('caps the backoff at the maximum delay plus jitter', () {
      final interceptor = RetryInterceptor(dio: Dio(), random: Random(1));
      final ceiling =
          NetworkConstants.retryMaxDelay.inMilliseconds *
          (1 + NetworkConstants.retryJitterRatio);

      expect(
        interceptor.backoffFor(10).inMilliseconds,
        lessThanOrEqualTo(ceiling),
      );
    });
  });
}
