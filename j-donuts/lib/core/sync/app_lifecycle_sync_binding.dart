import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/connectivity/connectivity_service.dart';
import 'package:jdonuts/core/sync/sync_coordinator.dart';
import 'package:jdonuts/core/sync/sync_policy.dart';

/// Re-checks reachability and requests a sync whenever the app resumes.
class AppLifecycleSyncBinding {
  AppLifecycleSyncBinding({
    required this._syncCoordinator,
    required this._connectivityService,
  });

  final SyncCoordinator _syncCoordinator;
  final ConnectivityService _connectivityService;
  AppLifecycleListener? _listener;

  void attach() => _listener ??= AppLifecycleListener(onResume: _onResume);

  void _onResume() {
    unawaited(_connectivityService.recheck());
    unawaited(_syncCoordinator.requestSync(SyncTrigger.appResume));
  }

  void detach() {
    _listener?.dispose();
    _listener = null;
  }
}
