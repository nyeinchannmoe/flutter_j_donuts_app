import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/module/auth/domain/formatters/countdown_format.dart';

void main() {
  group('formatCountdown', () {
    test('formats five minutes', () {
      expect(formatCountdown(const Duration(minutes: 5)), '5:00');
    });

    test('formats four minutes fifty-eight seconds', () {
      expect(
        formatCountdown(const Duration(minutes: 4, seconds: 58)),
        '4:58',
      );
    });

    test('formats zero', () {
      expect(formatCountdown(Duration.zero), '0:00');
    });

    test('clamps negative values to zero', () {
      expect(formatCountdown(const Duration(seconds: -3)), '0:00');
    });
  });
}
