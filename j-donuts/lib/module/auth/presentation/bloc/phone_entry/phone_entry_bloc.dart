import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/usecases/request_otp.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

part 'phone_entry_bloc.freezed.dart';
part 'phone_entry_event.dart';
part 'phone_entry_state.dart';

class PhoneEntryBloc extends Bloc<PhoneEntryEvent, PhoneEntryState> {
  PhoneEntryBloc({required this._requestOtp}) : super(const PhoneEntryState()) {
    on<PhoneEntryChanged>(_onChanged);
    on<PhoneEntryFocusChanged>(_onFocusChanged);
    on<PhoneEntrySubmitted>(_onSubmitted, transformer: droppable());
  }

  final RequestOtp _requestOtp;

  void _onChanged(PhoneEntryChanged event, Emitter<PhoneEntryState> emit) {
    if (state.submitting) return;
    emit(
      PhoneEntryState(
        phoneE164: AuthValidators.normalizeNationalPhone(
          event.input,
        ).valueOrNull,
      ),
    );
  }

  void _onFocusChanged(
    PhoneEntryFocusChanged event,
    Emitter<PhoneEntryState> emit,
  ) {
    emit(
      state.copyWith(showInvalid: !event.focused && state.phoneE164 == null),
    );
  }

  Future<void> _onSubmitted(
    PhoneEntrySubmitted event,
    Emitter<PhoneEntryState> emit,
  ) async {
    final phone = state.phoneE164;
    if (phone == null) return;
    emit(state.copyWith(submitting: true, codeSent: false, failure: null));
    final result = await _requestOtp(phone);
    emit(
      state.copyWith(
        submitting: false,
        codeSent: result is Ok<Unit>,
        failure: result.failureOrNull,
      ),
    );
  }
}
