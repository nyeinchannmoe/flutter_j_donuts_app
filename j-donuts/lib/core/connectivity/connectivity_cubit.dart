import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:jdonuts/core/connectivity/connection_status.dart';
import 'package:jdonuts/core/connectivity/connectivity_service.dart';
import 'package:jdonuts/core/sync/sync_coordinator.dart';
import 'package:jdonuts/core/sync/sync_policy.dart';

/// App-level connection state that drives the offline banner and triggers
/// a sync when the device comes back online.
class ConnectivityCubit extends Cubit<ConnectionStatus> {
  ConnectivityCubit({
    required ConnectivityService service,
    required this._syncCoordinator,
  }) : super(service.current) {
    _subscription = service.changes.listen(_onStatusChanged);
  }

  final SyncCoordinator _syncCoordinator;
  late final StreamSubscription<ConnectionStatus> _subscription;

  void _onStatusChanged(ConnectionStatus status) {
    final wasOffline = state.isOffline;
    emit(status);
    if (wasOffline && status == ConnectionStatus.online) {
      unawaited(_syncCoordinator.requestSync(SyncTrigger.reconnected));
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
