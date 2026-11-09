part of 'registration_bloc.dart';

sealed class RegistrationEvent {
  const RegistrationEvent();
}

final class RegistrationNameChanged extends RegistrationEvent {
  const RegistrationNameChanged({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;
}

final class RegistrationDateOfBirthChanged extends RegistrationEvent {
  const RegistrationDateOfBirthChanged(this.dateOfBirth);

  final DateTime dateOfBirth;
}

final class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted();
}
