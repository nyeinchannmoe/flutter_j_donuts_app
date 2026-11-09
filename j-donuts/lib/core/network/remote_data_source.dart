import 'package:dio/dio.dart';
import 'package:jdonuts/core/database/seed/catalog_import_runner.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/network/api_envelope.dart';
import 'package:jdonuts/core/network/network_constants.dart';
import 'package:jdonuts/core/result/result.dart';

/// Source of catalog refreshes. The payload has the same shape as the
/// bundled seed so the same importers can apply it.
abstract interface class RemoteDataSource {
  Future<Result<CatalogPayload>> fetchCatalog();
}

/// Null Object used while no backend exists: succeeds with an empty
/// payload and never touches the network.
class NoopRemoteDataSource implements RemoteDataSource {
  const NoopRemoteDataSource();

  @override
  Future<Result<CatalogPayload>> fetchCatalog() async => const Ok({});
}

/// Fetches `GET /v1/catalog` and unwraps the response envelope.
class DioRemoteDataSource implements RemoteDataSource {
  const DioRemoteDataSource({required this._dio, required this._logger});

  final Dio _dio;
  final AppLogger _logger;

  @override
  Future<Result<CatalogPayload>> fetchCatalog() async {
    try {
      final response = await _dio.get<Object?>(NetworkConstants.catalogPath);
      return ApiEnvelope.parse(response.data);
    } on DioException catch (error, stackTrace) {
      _logger.warning(
        'Catalog fetch failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Err(_failureFor(error, stackTrace));
    }
  }

  static AppFailure _failureFor(DioException error, StackTrace stackTrace) =>
      switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => TimeoutFailure(
          cause: error,
          stackTrace: stackTrace,
        ),
        _ => NetworkFailure(cause: error, stackTrace: stackTrace),
      };
}
