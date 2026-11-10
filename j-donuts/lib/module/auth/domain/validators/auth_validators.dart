import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';

/// Pure input rules for the auth flow.
abstract final class AuthValidators {
  /// Myanmar country calling code.
  static const String myanmarCallingCode = '+95';

  /// National field: optional trunk 0, then 9 and 7 to 9 digits.
  static final RegExp _nationalMobile = RegExp(r'^0?(9\d{7,9})$');

  /// Optional +95, 95 or trunk 0, then a mobile number: 9 and 7 to 9 digits.
  static final RegExp _myanmarMobile = RegExp(r'^(?:\+?95|0)?(9\d{7,9})$');
  static final RegExp _separators = RegExp(r'[\s\-().]');
  static final RegExp _nonDigits = RegExp(r'\D');

  /// Normalizes the editable national phone field (after the +95 prefix) to
  /// E.164. Country-code prefixes belong in [toMyanmarE164], not here.
  static Result<String> normalizeNationalPhone(String input) {
    final digits = input.replaceAll(_separators, '');
    final match = _nationalMobile.firstMatch(digits);
    if (match == null || match.end != digits.length) {
      return const Err(ValidationFailure());
    }
    return Ok('$myanmarCallingCode${match.group(1)}');
  }

  /// National digits without the +95 prefix, for prefilling the phone field.
  static String? nationalDigitsFromE164(String phoneE164) {
    if (!phoneE164.startsWith(myanmarCallingCode)) return null;
    return phoneE164.substring(myanmarCallingCode.length);
  }

  static const int otpLength = 6;
  static const String otpEmptyCode = 'auth.otp.empty';
  static const String otpTooShortCode = 'auth.otp.tooShort';
  static const String otpTooLongCode = 'auth.otp.tooLong';
  static const String otpNonDigitsCode = 'auth.otp.nonDigits';

  /// Normalises a Myanmar mobile number to E.164, or returns null when the
  /// input is not a valid mobile number.
  static String? toMyanmarE164(String input) {
    final digits = input.replaceAll(_separators, '');
    final match = _myanmarMobile.firstMatch(digits);
    if (match == null || match.end != digits.length) return null;
    return '$myanmarCallingCode${match.group(1)}';
  }

  /// Pure format check for a fixed-length numeric verification code.
  static Result<String> validateOtpCode(String code) {
    if (code.isEmpty) {
      return const Err(ValidationFailure(code: otpEmptyCode));
    }
    if (_nonDigits.hasMatch(code)) {
      return const Err(ValidationFailure(code: otpNonDigitsCode));
    }
    if (code.length < otpLength) {
      return const Err(ValidationFailure(code: otpTooShortCode));
    }
    if (code.length > otpLength) {
      return const Err(ValidationFailure(code: otpTooLongCode));
    }
    return Ok(code);
  }

  static bool isOtpComplete(String code) => validateOtpCode(code) is Ok;

  /// Max length after [normalizePersonName].
  static const int personNameMaxLength = 50;

  /// Soft keyboard limit before abuse; validation still uses
  /// [personNameMaxLength].
  static const int personNameInputLimit = 80;

  static const String firstNameRequiredCode = 'auth.firstName.required';
  static const String firstNameTooLongCode = 'auth.firstName.tooLong';
  static const String firstNameInvalidCode = 'auth.firstName.invalid';
  static const String lastNameTooLongCode = 'auth.lastName.tooLong';
  static const String lastNameInvalidCode = 'auth.lastName.invalid';

  static final RegExp _repeatedWhitespace = RegExp(r'\s+');
  static final RegExp _personNameChars = RegExp(
    r'^[\p{L}\p{M} ]+$',
    unicode: true,
  );

  /// Trims ends and collapses inner whitespace to a single space.
  static String normalizePersonName(String input) =>
      input.trim().replaceAll(_repeatedWhitespace, ' ');

  /// Display name stored on the member profile: first, or first plus last.
  static String formatFullName(String firstName, String? lastName) {
    final last = lastName == null ? '' : normalizePersonName(lastName);
    if (last.isEmpty) return firstName;
    return '$firstName $last';
  }

  /// Required given name: 1 to [personNameMaxLength] letters and spaces.
  static Result<String> validateFirstName(String input) {
    final value = normalizePersonName(input);
    if (value.isEmpty) {
      return const Err(ValidationFailure(code: firstNameRequiredCode));
    }
    return _validatePersonName(
      value,
      tooLongCode: firstNameTooLongCode,
      invalidCode: firstNameInvalidCode,
    );
  }

  /// Optional family name; empty is valid, otherwise same rules as first name.
  static Result<String> validateLastName(String input) {
    final value = normalizePersonName(input);
    if (value.isEmpty) return const Ok('');
    return _validatePersonName(
      value,
      tooLongCode: lastNameTooLongCode,
      invalidCode: lastNameInvalidCode,
    );
  }

  static Result<String> _validatePersonName(
    String value, {
    required String tooLongCode,
    required String invalidCode,
  }) {
    if (value.length > personNameMaxLength) {
      return Err(ValidationFailure(code: tooLongCode));
    }
    if (!_personNameChars.hasMatch(value)) {
      return Err(ValidationFailure(code: invalidCode));
    }
    return Ok(value);
  }

  static bool isNameValid(String firstName) =>
      validateFirstName(firstName) is Ok;

  /// Youngest age allowed to register.
  static const int minimumAge = 13;

  /// Oldest birth year accepted by the date-of-birth step.
  static const int earliestBirthYear = 1900;

  static const String dobNotRealCode = 'auth.dob.notReal';
  static const String dobFutureCode = 'auth.dob.future';
  static const String dobTooYoungCode = 'auth.dob.tooYoung';

  static DateTime earliestDateOfBirth() => DateTime(earliestBirthYear);

  /// Members must be at least [minimumAge] years old on [today].
  ///
  /// Clamps 29 February onto 28 February when the cutoff year is not a leap
  /// year so DateTime cannot roll the cutoff into March.
  static DateTime latestDateOfBirth(DateTime today) {
    final year = today.year - minimumAge;
    final month = today.month;
    final day = today.day;
    final isLeapDay = month == 2 && day == 29;
    final safeDay = isLeapDay && !_isLeapYear(year) ? 28 : day;
    return DateTime(year, month, safeDay);
  }

  static bool _isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static bool isDateOfBirthValid(DateTime dateOfBirth, DateTime today) =>
      !dateOfBirth.isAfter(latestDateOfBirth(today)) &&
      !dateOfBirth.isBefore(earliestDateOfBirth());
}
