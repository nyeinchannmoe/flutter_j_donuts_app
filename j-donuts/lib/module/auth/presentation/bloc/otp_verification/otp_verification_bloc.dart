import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/usecases/verify_otp.dart';

part 'otp_verification_bloc.freezed.dart';
part 'otp_verification_event.dart';
part 'otp_verification_state.dart';

class OtpVerificationBloc
    extends Bloc<OtpVerificationEvent, OtpVerificationState> {
  OtpVerificationBloc({required this._verifyOtp})
    : super(const OtpVerificationState.idle()) {
    on<OtpCodeSubmitted>(_onSubmitted, transformer: droppable());
  }

  final VerifyOtp _verifyOtp;

  Future<void> _onSubmitted(
    OtpCodeSubmitted event,
    Emitter<OtpVerificationState> emit,
  ) async {
    final failedAttempts = switch (state) {
      OtpRejected(:final failedAttempts) => failedAttempts,
      _ => 0,
    };
    emit(const OtpVerificationState.verifying());
    final result = await _verifyOtp(
      phoneE164: event.phoneE164,
      code: event.code,
      existingAccountOnly: event.existingAccountOnly,
    );
    emit(switch (result) {
      Ok(:final value) => OtpVerificationState.verified(
        isRegistered: value.isRegistered,
      ),
      Err(:final failure) => OtpVerificationState.rejected(
        failure: failure,
        failedAttempts: failedAttempts + 1,
      ),
    });
  }
}
