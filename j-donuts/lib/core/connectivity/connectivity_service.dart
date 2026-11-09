import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:jdonuts/core/connectivity/connection_status.dart';
import 'package:jdonuts/core/connectivity/reachability_checker.dart';

/// Combines interface changes from connectivity_plus with a real
/// reachability check. Interface events are debounced because platforms
/// emit bursts while switching networks.
class ConnectivityService {
  ConnectivityService({
    required this._connectivity,
    required this._reachability,
    this.debounce = defaultDebounce,
  });

  static const Duration defaultDebounce = Duration(milliseconds: 600);

  final Connectivity _connectivity;
  final ReachabilityChecker _reachability;
  final Duration debounce;

  final StreamController<ConnectionStatus> _controller =
      StreamController<ConnectionStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounceTimer;
  ConnectionStatus _current = ConnectionStatus.unknown;

  ConnectionStatus get current => _current;

  /// Distinct status changes after [start].
  Stream<ConnectionStatus> get changes => _controller.stream;

  Future<void> start() async {
    _subscription ??= _connectivity.onConnectivityChanged.listen(
      (_) => _scheduleCheck(),
    );
    await recheck();
  }

  /// Runs an immediate check, for example when the app resumes.
  Future<ConnectionStatus> recheck() async {
    final interfaces = await _connectivity.checkConnectivity();
    final hasInterface = interfaces.any(
      (result) => result != ConnectivityResult.none,
    );
    final reachable = hasInterface && await _reachability.isReachable();
    _update(reachable ? ConnectionStatus.online : ConnectionStatus.offline);
    return _current;
  }

  void _scheduleCheck() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, recheck);
  }

  void _update(ConnectionStatus status) {
    if (status == _current) return;
    _current = status;
    _controller.add(status);
  }

  Future<void> dispose() async {
    _debounceTimer?.cancel();
    await _subscription?.cancel();
    await _controller.close();
  }
}
