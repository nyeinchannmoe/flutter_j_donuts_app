part of 'registration_bloc.dart';

sealed class RegistrationEvent {
  const RegistrationEvent();
}

final class RegistrationFirstNameChanged extends RegistrationEvent {
  const RegistrationFirstNameChanged(this.value);

  final String value;
}

final class RegistrationLastNameChanged extends RegistrationEvent {
  const RegistrationLastNameChanged(this.value);

  final String value;
}

final class RegistrationFirstNameFocusChanged extends RegistrationEvent {
  const RegistrationFirstNameFocusChanged({required this.focused});

  final bool focused;
}

final class RegistrationLastNameFocusChanged extends RegistrationEvent {
  const RegistrationLastNameFocusChanged({required this.focused});

  final bool focused;
}

final class RegistrationNameSubmitted extends RegistrationEvent {
  const RegistrationNameSubmitted();
}

final class RegistrationDateOfBirthChanged extends RegistrationEvent {
  const RegistrationDateOfBirthChanged(this.dateOfBirth);

  final DateTime dateOfBirth;
}

final class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted();
}
