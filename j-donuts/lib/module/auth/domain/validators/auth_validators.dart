/// Pure input rules for the auth flow.
abstract final class AuthValidators {
  /// Myanmar country calling code.
  static const String myanmarCallingCode = '+95';

  static const int otpLength = 6;

  /// Optional +95, 95 or trunk 0, then a mobile number: 9 and 7 to 9 digits.
  static final RegExp _myanmarMobile = RegExp(r'^(?:\+?95|0)?(9\d{7,9})$');
  static final RegExp _separators = RegExp(r'[\s\-().]');
  static final RegExp _otp = RegExp('^\\d{$otpLength}\$');

  /// Normalises a Myanmar mobile number to E.164, or returns null when the
  /// input is not a valid mobile number.
  static String? toMyanmarE164(String input) {
    final digits = input.replaceAll(_separators, '');
    final match = _myanmarMobile.firstMatch(digits);
    if (match == null) return null;
    return '$myanmarCallingCode${match.group(1)}';
  }

  static bool isOtpComplete(String code) => _otp.hasMatch(code);

  static bool isNameValid(String firstName) => firstName.trim().isNotEmpty;

  static const int minimumAge = 13;
  static const int earliestBirthYear = 1900;

  static DateTime earliestDateOfBirth() => DateTime(earliestBirthYear);

  /// Members must be at least [minimumAge] years old on [today].
  static DateTime latestDateOfBirth(DateTime today) =>
      DateTime(today.year - minimumAge, today.month, today.day);

  static bool isDateOfBirthValid(DateTime dateOfBirth, DateTime today) =>
      !dateOfBirth.isAfter(latestDateOfBirth(today)) &&
      !dateOfBirth.isBefore(earliestDateOfBirth());
}
