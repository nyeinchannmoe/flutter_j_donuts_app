part of 'phone_entry_bloc.dart';

@freezed
abstract class PhoneEntryState with _$PhoneEntryState {
  const factory PhoneEntryState({
    String? phoneE164,
    @Default(false) bool showInvalid,
    @Default(false) bool submitting,
    @Default(false) bool codeSent,
    AppFailure? failure,
  }) = _PhoneEntryState;
}
