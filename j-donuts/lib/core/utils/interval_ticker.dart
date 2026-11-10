import 'dart:async';

/// Emits ticks on an interval so countdowns stay testable without real waits.
abstract interface class IntervalTicker {
  /// Single-subscription stream that fires once per [interval].
  Stream<void> periodic(Duration interval);
}

class SystemIntervalTicker implements IntervalTicker {
  const SystemIntervalTicker();

  @override
  Stream<void> periodic(Duration interval) => Stream<void>.periodic(interval);
}
