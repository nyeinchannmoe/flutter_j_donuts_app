import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';

/// The single place where failures become user-facing text.
extension FailureLocalization on AppFailure {
  String localizedMessage(AppLocalizations l10n) {
    if (code == FailureCodes.invalidCode) return l10n.failureInvalidOtp;
    if (code == FailureCodes.accountMissing) return l10n.failureAccountMissing;
    return switch (this) {
      StorageFailure() => l10n.failureStorage,
      NetworkFailure() => l10n.failureNetwork,
      TimeoutFailure() => l10n.failureTimeout,
      NotFoundFailure() => l10n.failureNotFound,
      ValidationFailure() => l10n.failureValidation,
      AuthFailure() => l10n.failureAuth,
      UnexpectedFailure() => l10n.failureUnexpected,
    };
  }

  /// Whether retrying the same request can succeed.
  bool get isRetryable => this is! NotFoundFailure;
}
