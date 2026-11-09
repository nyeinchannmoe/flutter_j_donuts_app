part of 'phone_entry_bloc.dart';

sealed class PhoneEntryEvent {
  const PhoneEntryEvent();
}

final class PhoneEntrySubmitted extends PhoneEntryEvent {
  const PhoneEntrySubmitted(this.phoneE164);

  final String phoneE164;
}
