import 'dart:async';

import 'package:jdonuts/core/utils/interval_ticker.dart';

/// Interval ticker that only advances when the test emits a tick.
class FakeIntervalTicker implements IntervalTicker {
  final StreamController<void> _controller =
      StreamController<void>.broadcast();

  @override
  Stream<void> periodic(Duration interval) => _controller.stream;

  void emit() => _controller.add(null);

  Future<void> dispose() => _controller.close();
}
