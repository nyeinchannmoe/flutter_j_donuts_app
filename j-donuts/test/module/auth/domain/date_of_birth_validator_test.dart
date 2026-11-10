import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/domain/validators/date_of_birth_validator.dart';

import '../../../helpers/fake_clock.dart';

void main() {
  final clock = FakeClock(DateTime(2026, 11, 10));

  DateOfBirthResult validate({
    int? year,
    int? month,
    int? day,
  }) => DateOfBirthValidator.validate(
    year: year,
    month: month,
    day: day,
    today: clock.now(),
  );

  DateOfBirthResult validateParts({
    required String dayText,
    required String yearText,
    int? month,
  }) => DateOfBirthValidator.validateParts(
    month: month,
    dayText: dayText,
    yearText: yearText,
    today: clock.now(),
  );

  group('DateOfBirthValidator', () {
    test('accepts a valid date', () {
      expect(
        validate(year: 2000, month: 5, day: 1),
        isA<DateOfBirthValid>().having(
          (r) => r.date,
          'date',
          DateTime(2000, 5),
        ),
      );
    });

    test('reports incomplete input', () {
      expect(
        validateParts(dayText: '1', yearText: '2000'),
        isA<DateOfBirthIncomplete>(),
      );
      expect(
        validateParts(month: 5, dayText: '', yearText: '2000'),
        isA<DateOfBirthIncomplete>(),
      );
      expect(
        validateParts(month: 5, dayText: '1', yearText: ''),
        isA<DateOfBirthIncomplete>(),
      );
    });

    test('rejects 31 April and 30 February', () {
      expect(
        validate(year: 2001, month: 4, day: 31),
        isA<DateOfBirthNotReal>(),
      );
      expect(
        validate(year: 2001, month: 2, day: 30),
        isA<DateOfBirthNotReal>(),
      );
    });

    test('accepts 29 February in leap years and rejects otherwise', () {
      expect(DateOfBirthValidator.isLeapYear(2000), isTrue);
      expect(DateOfBirthValidator.isLeapYear(2024), isTrue);
      expect(DateOfBirthValidator.isLeapYear(1900), isFalse);
      expect(DateOfBirthValidator.isLeapYear(2023), isFalse);
      expect(
        validate(year: 2000, month: 2, day: 29),
        isA<DateOfBirthValid>(),
      );
      expect(
        DateOfBirthValidator.validate(
          year: 2024,
          month: 2,
          day: 29,
          today: DateTime(2024 + AuthValidators.minimumAge, 2, 29),
        ),
        isA<DateOfBirthValid>(),
      );
      expect(
        validate(year: 1900, month: 2, day: 29),
        isA<DateOfBirthNotReal>(),
      );
      expect(
        validate(year: 2023, month: 2, day: 29),
        isA<DateOfBirthNotReal>(),
      );
    });

    test('rejects month 0 and 13', () {
      expect(validate(year: 2000, month: 0, day: 1), isA<DateOfBirthNotReal>());
      expect(
        validate(year: 2000, month: 13, day: 1),
        isA<DateOfBirthNotReal>(),
      );
    });

    test('rejects day 0 and 32', () {
      expect(validate(year: 2000, month: 1, day: 0), isA<DateOfBirthNotReal>());
      expect(
        validate(year: 2000, month: 1, day: 32),
        isA<DateOfBirthNotReal>(),
      );
    });

    test('rejects a year with fewer than 4 digits', () {
      expect(
        validateParts(month: 5, dayText: '1', yearText: '999'),
        isA<DateOfBirthNotReal>(),
      );
    });

    test('rejects a year below the minimum', () {
      expect(
        validate(
          year: AuthValidators.earliestBirthYear - 1,
          month: 12,
          day: 31,
        ),
        isA<DateOfBirthNotReal>(),
      );
    });

    test('rejects a future date', () {
      expect(
        validate(year: 2026, month: 11, day: 11),
        isA<DateOfBirthFuture>(),
      );
    });

    test('rejects today under the age rule', () {
      final today = clock.now();
      expect(
        validate(year: today.year, month: today.month, day: today.day),
        isA<DateOfBirthTooYoung>(),
      );
    });

    test('accepts exactly the minimum age today', () {
      final today = clock.now();
      expect(
        validate(
          year: today.year - AuthValidators.minimumAge,
          month: today.month,
          day: today.day,
        ),
        isA<DateOfBirthValid>(),
      );
    });

    test('rejects one day short of the minimum age', () {
      final today = clock.now();
      expect(
        validate(
          year: today.year - AuthValidators.minimumAge,
          month: today.month,
          day: today.day + 1,
        ),
        isA<DateOfBirthTooYoung>(),
      );
    });

    test('rejects when the birthday has not yet occurred this year', () {
      final local = FakeClock(DateTime(2026, 3));
      expect(
        DateOfBirthValidator.validate(
          year: 2026 - AuthValidators.minimumAge,
          month: 3,
          day: 2,
          today: local.now(),
        ),
        isA<DateOfBirthTooYoung>(),
      );
    });

    test('uses the named minimum age constant', () {
      final today = clock.now();
      final onBoundary = validate(
        year: today.year - AuthValidators.minimumAge,
        month: today.month,
        day: today.day,
      );
      final underByOneYear = validate(
        year: today.year - AuthValidators.minimumAge + 1,
        month: today.month,
        day: today.day,
      );
      expect(onBoundary, isA<DateOfBirthValid>());
      expect(underByOneYear, isA<DateOfBirthTooYoung>());
      expect(
        AuthValidators.latestDateOfBirth(today),
        DateTime(
          today.year - AuthValidators.minimumAge,
          today.month,
          today.day,
        ),
      );
    });
  });
}
