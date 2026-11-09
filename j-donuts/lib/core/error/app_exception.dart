import 'package:jdonuts/core/error/app_failure.dart';

/// Exception thrown inside the data layer when the failure type is already
/// known. guardResult and guardStream unwrap it into an Err with [failure].
final class AppException implements Exception {
  const AppException(this.failure);

  final AppFailure failure;

  @override
  String toString() => 'AppException($failure)';
}
