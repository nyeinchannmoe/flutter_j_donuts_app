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

final class RegistrationMonthSelected extends RegistrationEvent {
  const RegistrationMonthSelected(this.month);

  final int month;
}

final class RegistrationDayChanged extends RegistrationEvent {
  const RegistrationDayChanged(this.value);

  final String value;
}

final class RegistrationYearChanged extends RegistrationEvent {
  const RegistrationYearChanged(this.value);

  final String value;
}

final class RegistrationMonthFocusChanged extends RegistrationEvent {
  const RegistrationMonthFocusChanged({required this.focused});

  final bool focused;
}

final class RegistrationDayFocusChanged extends RegistrationEvent {
  const RegistrationDayFocusChanged({required this.focused});

  final bool focused;
}

final class RegistrationYearFocusChanged extends RegistrationEvent {
  const RegistrationYearFocusChanged({required this.focused});

  final bool focused;
}

final class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted();
}
