import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

void main() {
  group('toMyanmarE164', () {
    test('normalises local, national and international forms', () {
      const expected = '+959123456789';
      for (final input in [
        '09123456789',
        '9123456789',
        '959123456789',
        '+959123456789',
        '09 123-456 789',
        '(09) 123.456.789',
      ]) {
        expect(AuthValidators.toMyanmarE164(input), expected, reason: input);
      }
    });

    test('accepts 8 to 10 digit mobile numbers', () {
      expect(AuthValidators.toMyanmarE164('0912345678'), '+95912345678');
      expect(AuthValidators.toMyanmarE164('091234567'), '+9591234567');
    });

    test('rejects landlines, short, long and non-numeric input', () {
      for (final input in [
        '',
        '01234567',
        '0912345',
        '0912345678901',
        '+15551234567',
        'nine one two',
      ]) {
        expect(AuthValidators.toMyanmarE164(input), isNull, reason: input);
      }
    });
  });

  group('isOtpComplete', () {
    test('needs exactly six digits', () {
      expect(AuthValidators.isOtpComplete('123456'), isTrue);
      expect(AuthValidators.isOtpComplete('12345'), isFalse);
      expect(AuthValidators.isOtpComplete('1234567'), isFalse);
      expect(AuthValidators.isOtpComplete('12345a'), isFalse);
    });
  });

  group('isNameValid', () {
    test('needs a non-blank first name', () {
      expect(AuthValidators.isNameValid('Su'), isTrue);
      expect(AuthValidators.isNameValid('   '), isFalse);
      expect(AuthValidators.isNameValid(''), isFalse);
    });
  });

  group('isDateOfBirthValid', () {
    final today = DateTime(2026, 11, 9);

    test('accepts a member who turns 13 today', () {
      expect(
        AuthValidators.isDateOfBirthValid(DateTime(2013, 11, 9), today),
        isTrue,
      );
    });

    test('rejects a member one day short of 13', () {
      expect(
        AuthValidators.isDateOfBirthValid(DateTime(2013, 11, 10), today),
        isFalse,
      );
    });

    test('rejects dates before the earliest birth year', () {
      expect(
        AuthValidators.isDateOfBirthValid(DateTime(1899, 12, 31), today),
        isFalse,
      );
      expect(
        AuthValidators.isDateOfBirthValid(
          AuthValidators.earliestDateOfBirth(),
          today,
        ),
        isTrue,
      );
    });
  });
}
