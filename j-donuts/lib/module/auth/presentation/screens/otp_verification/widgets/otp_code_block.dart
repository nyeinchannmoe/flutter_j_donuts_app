import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/extensions/failure_localization.dart';
import 'package:jdonuts/core/widgets/inputs/segmented_code_field.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/presentation/bloc/otp_verification/otp_verification_bloc.dart';

class OtpCodeBlock extends StatelessWidget {
  const OtpCodeBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final slice = context.select<OtpVerificationBloc, _CodeSlice>(_sliceOf);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CodeField(slice: slice),
        if (slice.failure != null || slice.locked)
          _CodeMessage(slice: slice),
      ],
    );
  }

  static _CodeSlice _sliceOf(OtpVerificationBloc bloc) => _CodeSlice(
    code: bloc.state.code,
    hasError: bloc.state.failure != null && !bloc.state.locked,
    locked: bloc.state.locked,
    verifying: bloc.state.verifying,
    shakeEpoch: bloc.state.shakeEpoch,
    failure: bloc.state.failure,
  );
}

class _CodeField extends StatelessWidget {
  const _CodeField({required this.slice});

  final _CodeSlice slice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AutofillGroup(
      child: SegmentedCodeField(
        length: AuthValidators.otpLength,
        value: slice.code,
        hasError: slice.hasError,
        enabled: !slice.locked && !slice.verifying,
        isLoading: slice.verifying,
        shakeEpoch: slice.shakeEpoch,
        semanticsLabel: l10n.otpCodeSemantics(
          slice.code.length,
          AuthValidators.otpLength,
        ),
        onChanged: (code) =>
            context.read<OtpVerificationBloc>().add(OtpCodeChanged(code)),
        onCompleted: (_) {},
      ),
    );
  }
}

class _CodeMessage extends StatelessWidget {
  const _CodeMessage({required this.slice});

  final _CodeSlice slice;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = slice.locked
        ? l10n.otpLockedMessage
        : slice.failure!.localizedMessage(l10n);
    return Padding(
      padding: EdgeInsets.only(top: context.spacing.sm),
      child: Semantics(
        liveRegion: true,
        child: Text(
          message,
          style: context.typography.label.copyWith(
            color: context.colors.danger,
          ),
        ),
      ),
    );
  }
}

@immutable
class _CodeSlice {
  const _CodeSlice({
    required this.code,
    required this.hasError,
    required this.locked,
    required this.verifying,
    required this.shakeEpoch,
    required this.failure,
  });

  final String code;
  final bool hasError;
  final bool locked;
  final bool verifying;
  final int shakeEpoch;
  final AppFailure? failure;

  @override
  bool operator ==(Object other) =>
      other is _CodeSlice &&
      code == other.code &&
      hasError == other.hasError &&
      locked == other.locked &&
      verifying == other.verifying &&
      shakeEpoch == other.shakeEpoch &&
      failure == other.failure;

  @override
  int get hashCode =>
      Object.hash(code, hasError, locked, verifying, shakeEpoch, failure);
}
