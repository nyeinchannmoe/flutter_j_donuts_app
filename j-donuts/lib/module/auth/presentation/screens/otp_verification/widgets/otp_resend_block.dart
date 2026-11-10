import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/module/auth/domain/formatters/countdown_format.dart';
import 'package:jdonuts/module/auth/presentation/bloc/otp_verification/otp_verification_bloc.dart';

class OtpResendBlock extends StatelessWidget {
  const OtpResendBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final slice = context.select<OtpVerificationBloc, (Duration, bool)>(
      (bloc) => (bloc.state.remaining, bloc.state.canResend),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.otpDidNotReceive,
          style: context.typography.body.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        SizedBox(height: context.spacing.xs),
        if (slice.$2)
          OtpResendAction(
            onPressed: () => context.read<OtpVerificationBloc>().add(
              const OtpResendRequested(),
            ),
          )
        else
          _CountdownLine(remaining: slice.$1),
      ],
    );
  }
}

class _CountdownLine extends StatelessWidget {
  const _CountdownLine({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final body = context.typography.body;
    return Text.rich(
      TextSpan(
        style: body.copyWith(color: colors.textPrimary),
        children: [
          TextSpan(text: l10n.otpResendLead),
          TextSpan(
            text: formatCountdown(remaining),
            style: body.copyWith(color: colors.accent),
          ),
          TextSpan(text: l10n.otpResendTrail),
        ],
      ),
    );
  }
}

class OtpResendAction extends StatelessWidget {
  const OtpResendAction({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final target = context.spacing.xxxl;
    return Semantics(
      button: true,
      label: context.l10n.otpResendAction,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: target, minHeight: target),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.colors.accent,
              padding: EdgeInsets.symmetric(horizontal: context.spacing.xs),
              minimumSize: Size(target, target),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: context.typography.bodyStrong.copyWith(
                color: context.colors.accent,
              ),
            ),
            onPressed: onPressed,
            child: Text(context.l10n.otpResendAction),
          ),
        ),
      ),
    );
  }
}
