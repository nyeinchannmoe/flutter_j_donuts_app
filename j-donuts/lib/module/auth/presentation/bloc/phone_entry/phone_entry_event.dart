part of 'phone_entry_bloc.dart';

sealed class PhoneEntryEvent {
  const PhoneEntryEvent();
}

final class PhoneEntryChanged extends PhoneEntryEvent {
  const PhoneEntryChanged(this.input);

  final String input;
}

final class PhoneEntryFocusChanged extends PhoneEntryEvent {
  const PhoneEntryFocusChanged({required this.focused});

  final bool focused;
}

final class PhoneEntrySubmitted extends PhoneEntryEvent {
  const PhoneEntrySubmitted();
}
