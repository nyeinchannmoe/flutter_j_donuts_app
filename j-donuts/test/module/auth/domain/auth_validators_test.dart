import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

void main() {
  group('normalizeNationalPhone', () {
    test('normalizes trunk prefixes and visual separators', () {
      for (final input in ['09254135592', '9254135592', '09 254-135 592']) {
        expect(
          AuthValidators.normalizeNationalPhone(input).valueOrNull,
          '+959254135592',
        );
      }
    });

    test('rejects empty, short, long and non-mobile input', () {
      for (final input in [
        '',
        '9123456',
        '91234567890',
        '81234567',
        '+9591234567',
      ]) {
        expect(
          AuthValidators.normalizeNationalPhone(input).failureOrNull,
          isNotNull,
        );
      }
    });
  });

  group('nationalDigitsFromE164', () {
    test('strips the Myanmar calling code', () {
      expect(
        AuthValidators.nationalDigitsFromE164('+959254135592'),
        '9254135592',
      );
    });

    test('rejects values without the calling code', () {
      expect(AuthValidators.nationalDigitsFromE164('9254135592'), isNull);
    });
  });

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

  group('validateOtpCode', () {
    test('accepts exactly six digits', () {
      expect(AuthValidators.validateOtpCode('123456').valueOrNull, '123456');
      expect(AuthValidators.isOtpComplete('123456'), isTrue);
    });

    test('rejects empty, short, long and non-digit input', () {
      expect(
        AuthValidators.validateOtpCode('').failureOrNull?.code,
        AuthValidators.otpEmptyCode,
      );
      expect(
        AuthValidators.validateOtpCode('12345').failureOrNull?.code,
        AuthValidators.otpTooShortCode,
      );
      expect(
        AuthValidators.validateOtpCode('1234567').failureOrNull?.code,
        AuthValidators.otpTooLongCode,
      );
      expect(
        AuthValidators.validateOtpCode('12345a').failureOrNull?.code,
        AuthValidators.otpNonDigitsCode,
      );
      expect(AuthValidators.isOtpComplete('12345'), isFalse);
    });
  });

  group('normalizePersonName', () {
    test('trims ends and collapses repeated inner spaces', () {
      expect(AuthValidators.normalizePersonName('  Ye   Min  '), 'Ye Min');
      expect(AuthValidators.normalizePersonName('\tSu\n '), 'Su');
    });
  });

  group('formatFullName', () {
    test('returns first name alone when last is missing or blank', () {
      expect(AuthValidators.formatFullName('Su', null), 'Su');
      expect(AuthValidators.formatFullName('Su', ''), 'Su');
      expect(AuthValidators.formatFullName('Su', '   '), 'Su');
    });

    test('joins first and last with a single space', () {
      expect(
        AuthValidators.formatFullName('Ye Min', 'Phyoe Win'),
        'Ye Min Phyoe Win',
      );
    });
  });

  group('validateFirstName', () {
    test('requires a non-blank value', () {
      expect(
        AuthValidators.validateFirstName('').failureOrNull?.code,
        AuthValidators.firstNameRequiredCode,
      );
      expect(
        AuthValidators.validateFirstName('   ').failureOrNull?.code,
        AuthValidators.firstNameRequiredCode,
      );
    });

    test('accepts one character and exactly fifty characters', () {
      expect(AuthValidators.validateFirstName('A').valueOrNull, 'A');
      expect(
        AuthValidators.validateFirstName('A' * 50).valueOrNull,
        'A' * 50,
      );
    });

    test('rejects fifty-one characters', () {
      expect(
        AuthValidators.validateFirstName('A' * 51).failureOrNull?.code,
        AuthValidators.firstNameTooLongCode,
      );
    });

    test('accepts Latin letters with inner spaces', () {
      expect(AuthValidators.validateFirstName('Ye Min').valueOrNull, 'Ye Min');
    });

    test('accepts Myanmar names with vowel signs and spaces', () {
      expect(AuthValidators.validateFirstName('သီဟ').valueOrNull, 'သီဟ');
      expect(AuthValidators.validateFirstName('အောင်').valueOrNull, 'အောင်');
      expect(
        AuthValidators.validateFirstName('မောင် မောင်').valueOrNull,
        'မောင် မောင်',
      );
    });

    test('rejects Latin digits, Myanmar digits and symbols', () {
      expect(
        AuthValidators.validateFirstName('Ye1').failureOrNull?.code,
        AuthValidators.firstNameInvalidCode,
      );
      expect(
        AuthValidators.validateFirstName('မောင်၁').failureOrNull?.code,
        AuthValidators.firstNameInvalidCode,
      );
      expect(
        AuthValidators.validateFirstName('Ye@Min').failureOrNull?.code,
        AuthValidators.firstNameInvalidCode,
      );
    });
  });

  group('validateLastName', () {
    test('allows empty or whitespace-only values', () {
      expect(AuthValidators.validateLastName('').valueOrNull, '');
      expect(AuthValidators.validateLastName('   ').valueOrNull, '');
    });

    test('rejects digits when present', () {
      expect(
        AuthValidators.validateLastName('Win2').failureOrNull?.code,
        AuthValidators.lastNameInvalidCode,
      );
    });
  });

  group('isNameValid', () {
    test('needs a valid first name', () {
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

    test('clamps Feb 29 cutoffs onto Feb 28 in non-leap years', () {
      final leapToday = DateTime(2028, 2, 29);
      expect(
        AuthValidators.latestDateOfBirth(leapToday),
        DateTime(2015, 2, 28),
      );
      expect(
        AuthValidators.isDateOfBirthValid(DateTime(2015, 3), leapToday),
        isFalse,
      );
    });
  });
}
