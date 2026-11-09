import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/network/interceptors/logging_interceptor.dart';
import 'package:jdonuts/core/network/interceptors/retry_interceptor.dart';
import 'package:jdonuts/core/network/network_constants.dart';

/// Builds the single configured Dio instance.
abstract final class DioFactory {
  static Dio create({required String baseUrl, required AppLogger logger}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: _withVersionPath(baseUrl),
        connectTimeout: NetworkConstants.connectTimeout,
        sendTimeout: NetworkConstants.sendTimeout,
        receiveTimeout: NetworkConstants.receiveTimeout,
      ),
    );
    dio.interceptors.add(RetryInterceptor(dio: dio));
    if (kDebugMode) dio.interceptors.add(LoggingInterceptor(logger));
    return dio;
  }

  static String _withVersionPath(String baseUrl) {
    final trimmed = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$trimmed${NetworkConstants.apiVersionPath}';
  }
}
