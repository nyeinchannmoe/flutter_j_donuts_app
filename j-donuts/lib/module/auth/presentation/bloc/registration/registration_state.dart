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
    DateTime? dateOfBirth,
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

  bool get canSubmit =>
      hasName &&
      isLastNameValid &&
      dateOfBirth != null &&
      status != RegistrationStatus.submitting;
}
