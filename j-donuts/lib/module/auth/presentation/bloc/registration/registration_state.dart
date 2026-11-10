part of 'registration_bloc.dart';

enum RegistrationStatus { editing, submitting, completed, failed }

@freezed
abstract class RegistrationState with _$RegistrationState {
  const factory RegistrationState({
    @Default('') String firstName,
    @Default('') String lastName,
    @Default(false) bool firstNameTouched,
    @Default(false) bool lastNameTouched,
    @Default(false) bool nameSubmitting,
    @Default(0) int nameAdvanceToken,
    int? month,
    @Default('') String dayText,
    @Default('') String yearText,
    @Default(false) bool monthTouched,
    @Default(false) bool dayTouched,
    @Default(false) bool yearTouched,
    @Default(0) int dayFocusToken,
    @Default(RegistrationStatus.editing) RegistrationStatus status,
    AppFailure? failure,
  }) = _RegistrationState;

  const RegistrationState._();

  bool get isFirstNameValid =>
      AuthValidators.validateFirstName(firstName) is Ok;

  bool get isLastNameValid => AuthValidators.validateLastName(lastName) is Ok;

  bool get canContinueName =>
      isFirstNameValid && isLastNameValid && !nameSubmitting;

  String? get firstNameErrorCode {
    if (!firstNameTouched) return null;
    return AuthValidators.validateFirstName(firstName).failureOrNull?.code;
  }

  String? get lastNameErrorCode {
    if (!lastNameTouched) return null;
    return AuthValidators.validateLastName(lastName).failureOrNull?.code;
  }

  bool get hasName => isFirstNameValid;

  DateOfBirthResult dateOfBirthResult(DateTime today) =>
      DateOfBirthValidator.validateParts(
        month: month,
        dayText: dayText,
        yearText: yearText,
        today: today,
      );

  bool get dobPartsFilled =>
      month != null && dayText.isNotEmpty && yearText.isNotEmpty;

  bool get shouldRevealDobError =>
      dobPartsFilled || monthTouched || dayTouched || yearTouched;

  String? dobErrorCode(DateTime today) {
    if (!shouldRevealDobError) return null;
    return switch (dateOfBirthResult(today)) {
      DateOfBirthValid() || DateOfBirthIncomplete() => null,
      DateOfBirthNotReal() => AuthValidators.dobNotRealCode,
      DateOfBirthFuture() => AuthValidators.dobFutureCode,
      DateOfBirthTooYoung() => AuthValidators.dobTooYoungCode,
    };
  }

  bool canSubmit(DateTime today) {
    final result = dateOfBirthResult(today);
    return hasName &&
        isLastNameValid &&
        result is DateOfBirthValid &&
        status != RegistrationStatus.submitting;
  }

  DateTime? resolvedDateOfBirth(DateTime today) {
    final result = dateOfBirthResult(today);
    return result is DateOfBirthValid ? result.date : null;
  }
}
