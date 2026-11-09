import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';

/// Parses the `{data, error, meta}` response envelope used by the API.
abstract final class ApiEnvelope {
  static const String dataKey = 'data';
  static const String errorKey = 'error';
  static const String errorCodeKey = 'code';

  /// Returns the `data` object, or a typed failure when the envelope
  /// reports an error or is malformed.
  static Result<Map<String, Object?>> parse(Object? body) {
    if (body is! Map<String, Object?>) {
      return const Err(
        NetworkFailure(
          code: FailureCodes.envelope,
          cause: 'Response body is not an object',
        ),
      );
    }
    final error = body[errorKey];
    if (error != null) return Err(_failureFrom(error));
    final data = body[dataKey];
    if (data is! Map<String, Object?>) {
      return const Err(
        NetworkFailure(
          code: FailureCodes.envelope,
          cause: 'Envelope data is missing or not an object',
        ),
      );
    }
    return Ok(data);
  }

  static AppFailure _failureFrom(Object error) {
    final code = error is Map<String, Object?> ? error[errorCodeKey] : null;
    return NetworkFailure(
      code: code is String
          ? '${FailureCodes.network}.$code'
          : FailureCodes.network,
      cause: error,
    );
  }
}
