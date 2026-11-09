import 'package:jdonuts/core/error/app_failure.dart';

/// Observable state of the SyncCoordinator.
sealed class SyncStatus {
  const SyncStatus();
}

final class SyncIdle extends SyncStatus {
  const SyncIdle();
}

final class SyncInProgress extends SyncStatus {
  const SyncInProgress();
}

final class SyncSucceeded extends SyncStatus {
  const SyncSucceeded(this.completedAt);

  final DateTime completedAt;
}

final class SyncSkipped extends SyncStatus {
  const SyncSkipped();
}

/// Non-fatal: cached content stays visible.
final class SyncFailed extends SyncStatus {
  const SyncFailed(this.failure);

  final AppFailure failure;
}
