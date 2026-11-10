import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/entities/auth_flow_mode.dart';
import 'package:jdonuts/module/auth/domain/usecases/check_phone_registered.dart';
import 'package:jdonuts/module/auth/domain/usecases/request_otp.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

part 'phone_entry_bloc.freezed.dart';
part 'phone_entry_event.dart';
part 'phone_entry_state.dart';

class PhoneEntryBloc extends Bloc<PhoneEntryEvent, PhoneEntryState> {
  PhoneEntryBloc({
    required this._requestOtp,
    required this._checkPhoneRegistered,
    this.mode = AuthFlowMode.register,
  }) : super(const PhoneEntryState()) {
    on<PhoneEntrySeeded>(_onSeeded, transformer: droppable());
    on<PhoneEntryChanged>(_onChanged);
    on<PhoneEntryFocusChanged>(_onFocusChanged);
    on<PhoneEntrySubmitted>(_onSubmitted, transformer: droppable());
  }

  final RequestOtp _requestOtp;
  final CheckPhoneRegistered _checkPhoneRegistered;
  final AuthFlowMode mode;

  void _onSeeded(PhoneEntrySeeded event, Emitter<PhoneEntryState> emit) {
    if (state.submitting) return;
    emit(
      PhoneEntryState(
        phoneE164: AuthValidators.normalizeNationalPhone(
          event.nationalDigits,
        ).valueOrNull,
        nationalInput: event.nationalDigits,
      ),
    );
  }

  void _onChanged(PhoneEntryChanged event, Emitter<PhoneEntryState> emit) {
    if (state.submitting) return;
    emit(
      PhoneEntryState(
        phoneE164: AuthValidators.normalizeNationalPhone(
          event.input,
        ).valueOrNull,
        nationalInput: event.input,
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
    emit(
      state.copyWith(
        submitting: true,
        codeSent: false,
        failure: null,
        accountMissing: false,
      ),
    );
    if (await _loginBlocked(phone, emit)) return;
    final result = await _requestOtp(phone);
    if (isClosed) return;
    emit(
      state.copyWith(
        submitting: false,
        codeSent: result is Ok<Unit>,
        failure: result.failureOrNull,
      ),
    );
  }

  /// Returns true when log-in must stop (missing account or lookup error).
  Future<bool> _loginBlocked(
    String phone,
    Emitter<PhoneEntryState> emit,
  ) async {
    if (!mode.requiresExistingAccount) return false;
    final registered = await _checkPhoneRegistered(phone);
    if (isClosed) return true;
    return switch (registered) {
      Err(:final failure) => _emitLookupFailure(emit, failure),
      Ok(value: false) => _emitAccountMissing(emit),
      Ok() => false,
    };
  }

  bool _emitLookupFailure(Emitter<PhoneEntryState> emit, AppFailure failure) {
    emit(state.copyWith(submitting: false, failure: failure));
    return true;
  }

  bool _emitAccountMissing(Emitter<PhoneEntryState> emit) {
    emit(
      state.copyWith(
        submitting: false,
        accountMissing: true,
        failure: const AuthFailure(code: FailureCodes.accountMissing),
      ),
    );
    return true;
  }
}
