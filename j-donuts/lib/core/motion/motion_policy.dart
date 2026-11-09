import 'package:flutter/foundation.dart';
import 'package:jdonuts/core/motion/frame_budget_monitor.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';

/// Resolves the active MotionProfile from accessibility settings, the
/// measured frame budget and the app lifecycle.
class MotionPolicy extends ChangeNotifier {
  MotionPolicy({this._monitor}) {
    _monitor?.onSustainedJank = downgradeForJank;
  }

  final FrameBudgetMonitor? _monitor;
  MotionTier _ceiling = MotionTier.full;
  bool _appActive = true;

  /// Highest tier allowed after jank downgrades.
  MotionTier get ceiling => _ceiling;

  void startMonitoring() => _monitor?.attach();

  MotionProfile resolve({required bool disableAnimations}) => MotionProfile(
    tier: disableAnimations ? MotionTier.minimal : _ceiling,
    appActive: _appActive,
  );

  /// Steps down one tier. Never upgrades within a session.
  void downgradeForJank() {
    final next = _ceiling == MotionTier.full
        ? MotionTier.reduced
        : MotionTier.minimal;
    if (next == _ceiling) return;
    _ceiling = next;
    notifyListeners();
  }

  void updateAppActive({required bool isActive}) {
    if (_appActive == isActive) return;
    _appActive = isActive;
    notifyListeners();
  }

  @override
  void dispose() {
    _monitor?.detach();
    super.dispose();
  }
}
