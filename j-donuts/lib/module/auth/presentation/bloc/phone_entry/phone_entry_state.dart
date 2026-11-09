part of 'phone_entry_bloc.dart';

@freezed
sealed class PhoneEntryState with _$PhoneEntryState {
  const factory PhoneEntryState.idle() = PhoneEntryIdle;

  const factory PhoneEntryState.submitting() = PhoneEntrySubmitting;

  /// One-shot transition the screen reacts to by opening the OTP step.
  const factory PhoneEntryState.codeSent({required String phoneE164}) =
      PhoneEntryCodeSent;

  const factory PhoneEntryState.failure(AppFailure failure) = PhoneEntryFailure;
}
