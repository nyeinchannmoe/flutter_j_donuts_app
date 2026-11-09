import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/usecases/request_otp.dart';

part 'phone_entry_bloc.freezed.dart';
part 'phone_entry_event.dart';
part 'phone_entry_state.dart';

class PhoneEntryBloc extends Bloc<PhoneEntryEvent, PhoneEntryState> {
  PhoneEntryBloc({required this._requestOtp})
    : super(const PhoneEntryState.idle()) {
    on<PhoneEntrySubmitted>(_onSubmitted, transformer: droppable());
  }

  final RequestOtp _requestOtp;

  Future<void> _onSubmitted(
    PhoneEntrySubmitted event,
    Emitter<PhoneEntryState> emit,
  ) async {
    emit(const PhoneEntryState.submitting());
    final result = await _requestOtp(event.phoneE164);
    emit(switch (result) {
      Ok() => PhoneEntryState.codeSent(phoneE164: event.phoneE164),
      Err(:final failure) => PhoneEntryState.failure(failure),
    });
  }
}
