import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/utils/clock.dart';
import 'package:jdonuts/core/utils/interval_ticker.dart';
import 'package:jdonuts/module/auth/domain/otp_timing.dart';
import 'package:jdonuts/module/auth/domain/usecases/request_otp.dart';
import 'package:jdonuts/module/auth/domain/usecases/verify_otp.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

part 'otp_verification_bloc.freezed.dart';
part 'otp_verification_event.dart';
part 'otp_verification_state.dart';

class OtpVerificationBloc
    extends Bloc<OtpVerificationEvent, OtpVerificationState> {
  OtpVerificationBloc({
    required this._verifyOtp,
    required this._requestOtp,
    required Clock clock,
    required IntervalTicker ticker,
    this.resendWindow = OtpTiming.resendWindow,
    this.tickInterval = OtpTiming.tickInterval,
    this.maxFailedAttempts = OtpTiming.maxFailedAttempts,
  }) : _clock = clock,
       super(
         OtpVerificationState(
           resendAvailableAt: clock.now().add(resendWindow),
           remaining: resendWindow,
         ),
       ) {
    on<OtpVerificationStarted>(_onStarted, transformer: droppable());
    on<OtpCodeChanged>(_onCodeChanged, transformer: sequential());
    on<OtpCountdownTicked>(_onTick, transformer: sequential());
    on<OtpResendRequested>(_onResend, transformer: droppable());
    _tickSubscription = ticker.periodic(tickInterval).listen((_) {
      if (!isClosed) add(const OtpCountdownTicked());
    });
  }

  final VerifyOtp _verifyOtp;
  final RequestOtp _requestOtp;
  final Clock _clock;
  final Duration resendWindow;
  final Duration tickInterval;
  final int maxFailedAttempts;

  StreamSubscription<void>? _tickSubscription;
  String? _phoneE164;
  bool _existingAccountOnly = false;
  bool _submitInFlight = false;

  Future<void> _onStarted(
    OtpVerificationStarted event,
    Emitter<OtpVerificationState> emit,
  ) async {
    _phoneE164 = event.phoneE164;
    _existingAccountOnly = event.existingAccountOnly;
    emit(_restartCountdown(state.copyWith(code: '', failure: null)));
  }

  Future<void> _onCodeChanged(
    OtpCodeChanged event,
    Emitter<OtpVerificationState> emit,
  ) async {
    if (state.locked || state.verifying || state.isVerified) return;
    final digits = event.code.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > AuthValidators.otpLength
        ? digits.substring(0, AuthValidators.otpLength)
        : digits;
    if (clipped == state.code) return;
    emit(state.copyWith(code: clipped, failure: null));
    if (clipped.length == AuthValidators.otpLength) {
      await _submit(clipped, emit);
    }
  }

  Future<void> _submit(
    String code,
    Emitter<OtpVerificationState> emit,
  ) async {
    final phone = _phoneE164;
    if (phone == null || _submitInFlight || state.locked) return;
    _submitInFlight = true;
    emit(state.copyWith(verifying: true, failure: null));
    final result = await _verifyOtp(
      phoneE164: phone,
      code: code,
      existingAccountOnly: _existingAccountOnly,
    );
    _submitInFlight = false;
    if (isClosed) return;
    emit(switch (result) {
      Ok(:final value) => state.copyWith(
        verifying: false,
        verifiedIsRegistered: value.isRegistered,
        failure: null,
      ),
      Err(:final failure) => _rejected(failure),
    });
  }

  OtpVerificationState _rejected(AppFailure failure) {
    final attempts = state.failedAttempts + 1;
    final locked = attempts >= maxFailedAttempts;
    return state.copyWith(
      verifying: false,
      code: '',
      failedAttempts: attempts,
      locked: locked,
      failure: failure,
      shakeEpoch: state.shakeEpoch + 1,
    );
  }

  void _onTick(
    OtpCountdownTicked event,
    Emitter<OtpVerificationState> emit,
  ) {
    final remaining = _remainingUntil(state.resendAvailableAt);
    if (remaining == state.remaining) return;
    emit(state.copyWith(remaining: remaining));
  }

  Future<void> _onResend(
    OtpResendRequested event,
    Emitter<OtpVerificationState> emit,
  ) async {
    final phone = _phoneE164;
    if (phone == null || !state.canResend || state.verifying) return;
    emit(
      _restartCountdown(
        state.copyWith(
          code: '',
          failedAttempts: 0,
          locked: false,
          failure: null,
        ),
      ),
    );
    final result = await _requestOtp(phone);
    if (isClosed) return;
    if (result case Err(:final failure)) {
      emit(state.copyWith(failure: failure));
    }
  }

  OtpVerificationState _restartCountdown(OtpVerificationState current) {
    final availableAt = _clock.now().add(resendWindow);
    return current.copyWith(
      resendAvailableAt: availableAt,
      remaining: _remainingUntil(availableAt),
    );
  }

  Duration _remainingUntil(DateTime availableAt) {
    final delta = availableAt.difference(_clock.now());
    return delta.isNegative ? Duration.zero : delta;
  }

  @override
  Future<void> close() async {
    await _tickSubscription?.cancel();
    return super.close();
  }
}
