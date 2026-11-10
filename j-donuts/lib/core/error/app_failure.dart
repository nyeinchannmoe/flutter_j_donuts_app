import 'package:meta/meta.dart';

/// Typed failure hierarchy shared by every layer.
///
/// Failures compare by [code] and runtime type so tests and Blocs can match
/// them without caring about the underlying cause.
@immutable
sealed class AppFailure {
  const AppFailure({required this.code, this.cause, this.stackTrace});

  /// Stable, machine-readable identifier such as `storage.read`.
  final String code;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is AppFailure &&
      other.code == code;

  @override
  int get hashCode => Object.hash(runtimeType, code);

  @override
  String toString() => 'AppFailure($code${cause == null ? '' : ': $cause'})';
}

final class StorageFailure extends AppFailure {
  const StorageFailure({
    super.code = FailureCodes.storage,
    super.cause,
    super.stackTrace,
  });
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.code = FailureCodes.network,
    super.cause,
    super.stackTrace,
  });
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure({
    super.code = FailureCodes.timeout,
    super.cause,
    super.stackTrace,
  });
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({
    super.code = FailureCodes.notFound,
    super.cause,
    super.stackTrace,
  });
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure({
    super.code = FailureCodes.validation,
    super.cause,
    super.stackTrace,
  });
}

final class AuthFailure extends AppFailure {
  const AuthFailure({
    super.code = FailureCodes.auth,
    super.cause,
    super.stackTrace,
  });
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({
    super.code = FailureCodes.unexpected,
    super.cause,
    super.stackTrace,
  });
}

/// Failure codes shared by the kernel. Features define their own codes with
/// a dot suffix on the generic code, for example `auth.invalidOtp`.
abstract final class FailureCodes {
  static const String storage = 'storage';
  static const String network = 'network';
  static const String timeout = 'timeout';
  static const String notFound = 'notFound';
  static const String validation = 'validation';
  static const String auth = 'auth';
  static const String unexpected = 'unexpected';
  static const String invalidCode = 'auth.invalidCode';
  static const String accountMissing = 'auth.accountMissing';
  static const String seed = 'storage.seed';
  static const String envelope = 'network.envelope';
}
