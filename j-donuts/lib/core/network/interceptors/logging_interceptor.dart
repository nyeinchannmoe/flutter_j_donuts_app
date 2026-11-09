import 'package:dio/dio.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/network/network_constants.dart';

/// Logs requests and responses with sensitive headers redacted. Added to
/// Dio only in debug builds by DioFactory.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.debug(
      'HTTP ${options.method} ${options.uri} '
      'headers=${redactHeaders(options.headers)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.debug(
      'HTTP ${response.statusCode} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.warning(
      'HTTP ${err.type.name} ${err.requestOptions.uri}',
      error: err.error,
    );
    handler.next(err);
  }

  static Map<String, Object?> redactHeaders(Map<String, Object?> headers) => {
    for (final entry in headers.entries)
      entry.key:
          NetworkConstants.redactedHeaders.contains(
            entry.key.toLowerCase(),
          )
          ? NetworkConstants.redactedValue
          : entry.value,
  };
}
