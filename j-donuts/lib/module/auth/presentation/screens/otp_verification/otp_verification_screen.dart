import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/extensions/failure_localization.dart';
import 'package:jdonuts/core/motion/primitives/shake_on_trigger.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/core/widgets/inputs/app_text_field.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/presentation/bloc/otp_verification/otp_verification_bloc.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_scaffold.dart';

/// Code entry. Returning members are moved on by the router as soon as the
/// session is authenticated; new members continue via [onNewMemberVerified].
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    required this.phoneE164,
    required this.demoCode,
    required this.onNewMemberVerified,
    super.key,
  });

  final String phoneE164;

  /// Shown as a hint because this build uses a fake OTP provider.
  final String demoCode;
  final VoidCallback onNewMemberVerified;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!AuthValidators.isOtpComplete(_controller.text)) return;
    context.read<OtpVerificationBloc>().add(
      OtpCodeSubmitted(phoneE164: widget.phoneE164, code: _controller.text),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<OtpVerificationBloc, OtpVerificationState>(
        listenWhen: (previous, current) =>
            current is OtpVerified && !current.isRegistered,
        listener: (context, _) => widget.onNewMemberVerified(),
        builder: (context, state) => AuthStepScaffold(
          step: 2,
          title: context.l10n.otpTitle,
          action: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => AppButton(
              label: context.l10n.actionContinue,
              isLoading: state is OtpVerifying,
              onPressed: AuthValidators.isOtpComplete(value.text)
                  ? _submit
                  : null,
            ),
          ),
          child: _OtpBody(
            state: state,
            controller: _controller,
            phoneE164: widget.phoneE164,
            demoCode: widget.demoCode,
            onSubmitted: _submit,
          ),
        ),
      );
}

class _OtpBody extends StatelessWidget {
  const _OtpBody({
    required this.state,
    required this.controller,
    required this.phoneE164,
    required this.demoCode,
    required this.onSubmitted,
  });

  final OtpVerificationState state;
  final TextEditingController controller;
  final String phoneE164;
  final String demoCode;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rejected = switch (state) {
      final OtpRejected rejected => rejected,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.spacing.lg,
      children: [
        Text(l10n.otpSubtitle(phoneE164), style: context.typography.body),
        ShakeOnTrigger(
          trigger: rejected?.failedAttempts ?? 0,
          child: _codeField(l10n, rejected),
        ),
        Text(
          l10n.otpDemoHint(demoCode),
          style: context.typography.caption.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _codeField(AppLocalizations l10n, OtpRejected? rejected) =>
      AppTextField(
        controller: controller,
        label: l10n.otpFieldLabel,
        errorText: rejected?.failure.localizedMessage(l10n),
        autofocus: true,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(AuthValidators.otpLength),
        ],
        onSubmitted: (_) => onSubmitted(),
      );
}
