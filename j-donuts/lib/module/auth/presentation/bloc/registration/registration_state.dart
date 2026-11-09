part of 'registration_bloc.dart';

enum RegistrationStatus { editing, submitting, completed, failed }

@freezed
abstract class RegistrationState with _$RegistrationState {
  const factory RegistrationState({
    @Default('') String firstName,
    @Default('') String lastName,
    DateTime? dateOfBirth,
    @Default(RegistrationStatus.editing) RegistrationStatus status,
    AppFailure? failure,
  }) = _RegistrationState;

  const RegistrationState._();

  bool get hasName => AuthValidators.isNameValid(firstName);

  bool get canSubmit =>
      hasName && dateOfBirth != null && status != RegistrationStatus.submitting;
}
