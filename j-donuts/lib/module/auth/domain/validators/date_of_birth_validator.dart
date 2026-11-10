import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

/// Outcome of validating a date of birth from year, month and day parts.
sealed class DateOfBirthResult {
  const DateOfBirthResult();
}

/// All parts present and the calendar date is allowed.
final class DateOfBirthValid extends DateOfBirthResult {
  const DateOfBirthValid(this.date);

  final DateTime date;
}

/// At least one of month, day or year is still missing.
final class DateOfBirthIncomplete extends DateOfBirthResult {
  const DateOfBirthIncomplete();
}

/// The parts do not form a real calendar date.
final class DateOfBirthNotReal extends DateOfBirthResult {
  const DateOfBirthNotReal();
}

/// The date is after today.
final class DateOfBirthFuture extends DateOfBirthResult {
  const DateOfBirthFuture();
}

/// The member is younger than [AuthValidators.minimumAge].
final class DateOfBirthTooYoung extends DateOfBirthResult {
  const DateOfBirthTooYoung();
}

/// Pure date-of-birth rules. No Flutter imports.
abstract final class DateOfBirthValidator {
  static const int yearDigitCount = 4;
  static const int minMonth = 1;
  static const int maxMonth = 12;
  static const int minDay = 1;
  static const int february = 2;
  static const int leapDay = 29;
  static const int februaryCommonDays = 28;
  static const List<int> _daysInMonth = <int>[
    0,
    31,
    februaryCommonDays,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  ];

  /// Leap years are divisible by 4 and not by 100, or divisible by 400.
  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static int daysInMonth(int year, int month) {
    if (month == february && isLeapYear(year)) return leapDay;
    return _daysInMonth[month];
  }

  /// Validates [year], [month] and [day] against [today]'s calendar date.
  static DateOfBirthResult validate({
    required int? year,
    required int? month,
    required int? day,
    required DateTime today,
  }) {
    if (year == null || month == null || day == null) {
      return const DateOfBirthIncomplete();
    }
    if (!_isRealDate(year: year, month: month, day: day)) {
      return const DateOfBirthNotReal();
    }
    final date = DateTime(year, month, day);
    final todayDate = DateTime(today.year, today.month, today.day);
    if (date.isAfter(todayDate)) return const DateOfBirthFuture();
    final latest = AuthValidators.latestDateOfBirth(todayDate);
    if (date.isAfter(latest)) return const DateOfBirthTooYoung();
    return DateOfBirthValid(date);
  }

  /// Parses day and year text with the selected [month].
  static DateOfBirthResult validateParts({
    required int? month,
    required String dayText,
    required String yearText,
    required DateTime today,
  }) {
    if (month == null || dayText.isEmpty || yearText.isEmpty) {
      return const DateOfBirthIncomplete();
    }
    if (yearText.length != yearDigitCount) {
      return const DateOfBirthNotReal();
    }
    final day = int.tryParse(dayText);
    final year = int.tryParse(yearText);
    if (day == null || year == null) return const DateOfBirthNotReal();
    return validate(year: year, month: month, day: day, today: today);
  }

  static bool _isRealDate({
    required int year,
    required int month,
    required int day,
  }) {
    if (year < AuthValidators.earliestBirthYear) return false;
    if (year.toString().length != yearDigitCount) return false;
    if (month < minMonth || month > maxMonth) return false;
    if (day < minDay) return false;
    if (day > daysInMonth(year, month)) return false;
    final constructed = DateTime(year, month, day);
    return constructed.year == year &&
        constructed.month == month &&
        constructed.day == day;
  }
}
