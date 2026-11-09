import 'dart:async';

import 'package:jdonuts/core/error/app_exception.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/result/result.dart';

/// Builds the failure used when an exception has no more specific mapping.
typedef FailureFactory =
    AppFailure Function(Object error, StackTrace stackTrace);

AppFailure storageFailureFactory(Object error, StackTrace stackTrace) =>
    StorageFailure(cause: error, stackTrace: stackTrace);

AppFailure unexpectedFailureFactory(Object error, StackTrace stackTrace) =>
    UnexpectedFailure(cause: error, stackTrace: stackTrace);

/// Converts any thrown object into a typed [AppFailure].
AppFailure mapErrorToFailure(
  Object error,
  StackTrace stackTrace, {
  FailureFactory fallback = unexpectedFailureFactory,
}) => switch (error) {
  AppException(:final failure) => failure,
  TimeoutException() => TimeoutFailure(cause: error, stackTrace: stackTrace),
  _ => fallback(error, stackTrace),
};

/// Runs [body] and converts thrown exceptions into an [Err], logging them.
Future<Result<T>> guardResult<T>(
  Future<T> Function() body, {
  required AppLogger logger,
  FailureFactory fallback = storageFailureFactory,
}) async {
  try {
    return Ok(await body());
  } on Object catch (error, stackTrace) {
    final failure = mapErrorToFailure(error, stackTrace, fallback: fallback);
    logger.error(
      'Operation failed: $failure',
      error: error,
      stackTrace: stackTrace,
    );
    return Err(failure);
  }
}

/// Wraps [source] so data events become [Ok] and errors become [Err].
///
/// The stream keeps running after an error, so a later database change can
/// recover the UI without resubscribing.
Stream<Result<T>> guardStream<T>(
  Stream<T> source, {
  required AppLogger logger,
  FailureFactory fallback = storageFailureFactory,
}) => source.transform(
  StreamTransformer<T, Result<T>>.fromHandlers(
    handleData: (value, sink) => sink.add(Ok(value)),
    handleError: (error, stackTrace, sink) {
      final failure = mapErrorToFailure(error, stackTrace, fallback: fallback);
      logger.error(
        'Stream failed: $failure',
        error: error,
        stackTrace: stackTrace,
      );
      sink.add(Err(failure));
    },
  ),
);
