import 'package:jdonuts/core/utils/clock.dart';

/// Clock that only moves when the test says so.
class FakeClock implements Clock {
  FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;

  void advance(Duration duration) => current = current.add(duration);
}
