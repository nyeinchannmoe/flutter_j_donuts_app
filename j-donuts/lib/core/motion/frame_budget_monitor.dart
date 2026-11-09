import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:jdonuts/core/logging/app_logger.dart';

/// Watches frame timings and reports sustained jank.
///
/// Frames are grouped into windows of [windowSize]. A window is janky when
/// more than [jankRatioThreshold] of its frames exceed [frameBudget]. Only
/// [windowsBeforeDowngrade] consecutive janky windows trigger
/// [onSustainedJank] (hysteresis), and it fires at most once per session.
class FrameBudgetMonitor {
  FrameBudgetMonitor({
    required this._logger,
    this.frameBudget = defaultFrameBudget,
    this.windowSize = defaultWindowSize,
    this.jankRatioThreshold = defaultJankRatio,
    this.windowsBeforeDowngrade = defaultWindowsBeforeDowngrade,
  });

  /// 60 Hz budget with headroom for scheduling noise.
  static const Duration defaultFrameBudget = Duration(microseconds: 20000);
  static const int defaultWindowSize = 120;
  static const double defaultJankRatio = 0.25;
  static const int defaultWindowsBeforeDowngrade = 2;

  final AppLogger _logger;
  final Duration frameBudget;
  final int windowSize;
  final double jankRatioThreshold;
  final int windowsBeforeDowngrade;

  VoidCallback? onSustainedJank;
  int _framesInWindow = 0;
  int _jankyFramesInWindow = 0;
  int _consecutiveJankyWindows = 0;
  bool _reported = false;
  bool _attached = false;

  void attach() {
    if (_attached) return;
    _attached = true;
    SchedulerBinding.instance.addTimingsCallback(recordTimings);
  }

  void detach() {
    if (!_attached) return;
    _attached = false;
    SchedulerBinding.instance.removeTimingsCallback(recordTimings);
  }

  @visibleForTesting
  void recordTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      recordFrame(timing.totalSpan);
    }
  }

  @visibleForTesting
  void recordFrame(Duration totalSpan) {
    if (_reported) return;
    _framesInWindow++;
    if (totalSpan > frameBudget) _jankyFramesInWindow++;
    if (_framesInWindow >= windowSize) _closeWindow();
  }

  void _closeWindow() {
    final ratio = _jankyFramesInWindow / _framesInWindow;
    if (kProfileMode) {
      _logger.info('Frame window: ${(ratio * 100).round()}% over budget');
    }
    _consecutiveJankyWindows = ratio > jankRatioThreshold
        ? _consecutiveJankyWindows + 1
        : 0;
    _framesInWindow = 0;
    _jankyFramesInWindow = 0;
    if (_consecutiveJankyWindows >= windowsBeforeDowngrade) {
      _reported = true;
      _logger.warning('Sustained jank detected; reducing motion tier');
      onSustainedJank?.call();
    }
  }
}
