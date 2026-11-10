import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/extensions/failure_localization.dart';
import 'package:jdonuts/core/motion/primitives/morphing_progress_ring.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/core/widgets/inputs/prefixed_text_field.dart';
import 'package:jdonuts/core/widgets/legal_footer.dart';
import 'package:jdonuts/core/widgets/scaffold/step_page_scaffold.dart';
import 'package:jdonuts/module/auth/presentation/bloc/phone_entry/phone_entry_bloc.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_scaffold.dart';

class PhoneEntryScreen extends StatelessWidget {
  const PhoneEntryScreen({required this.onCodeSent, super.key});

  final ValueChanged<String> onCodeSent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final extent = context.iconSizes.lg - context.spacing.xxs;
    return BlocListener<PhoneEntryBloc, PhoneEntryState>(
      listenWhen: (previous, current) => !previous.codeSent && current.codeSent,
      listener: (context, state) => onCodeSent(state.phoneE164!),
      child: StepPageScaffold(
        title: context.l10n.phoneTitle,
        onBack: () => Navigator.maybePop(context),
        progress: MorphingProgressRing(
          progress: 1 / authStepCount,
          extent: extent,
          strokeWidth: extent * MorphingProgressRing.strokeFraction,
          trackColor: colors.tierColors.last,
          progressColor: colors.accent,
        ),
        content: const _PhoneInput(),
        action: const _ContinueAction(),
        supportingContent: _legal(context),
      ),
    );
  }

  Widget _legal(BuildContext context) {
    final l10n = context.l10n;
    void showNotice() => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.onboardingComingSoon)),
    );
    return LegalFooter(
      before: l10n.onboardingLegalBefore,
      terms: l10n.onboardingTerms,
      between: l10n.onboardingLegalBetween,
      privacy: l10n.onboardingPrivacy,
      after: l10n.onboardingLegalAfter,
      onTerms: showNotice,
      onPrivacy: showNotice,
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput();

  static const _maxLength = 20;
  static final List<TextInputFormatter> _formatters = [
    FilteringTextInputFormatter.allow(RegExp('[0-9 -]')),
    LengthLimitingTextInputFormatter(_maxLength),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.select<PhoneEntryBloc, PhoneEntryState>(
      (bloc) => bloc.state,
    );
    final bloc = context.read<PhoneEntryBloc>();
    final l10n = context.l10n;
    return PrefixedTextField(
      label: l10n.phoneFieldLabel,
      prefix: l10n.phoneCountryPrefix,
      errorText: state.showInvalid
          ? l10n.phoneInvalid
          : state.failure?.localizedMessage(l10n),
      readOnly: state.submitting,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: _formatters,
      onChanged: (value) => bloc.add(PhoneEntryChanged(value)),
      onFocusChanged: (focused) =>
          bloc.add(PhoneEntryFocusChanged(focused: focused)),
      onSubmitted: (_) => bloc.add(const PhoneEntrySubmitted()),
    );
  }
}

class _ContinueAction extends StatelessWidget {
  const _ContinueAction();

  @override
  Widget build(BuildContext context) {
    final (valid, busy) = context.select<PhoneEntryBloc, (bool, bool)>(
      (bloc) => (bloc.state.phoneE164 != null, bloc.state.submitting),
    );
    return AppButton(
      label: context.l10n.actionContinue,
      isLoading: busy,
      usePrimaryDisabledFill: true,
      onPressed: valid
          ? () =>
                context.read<PhoneEntryBloc>().add(const PhoneEntrySubmitted())
          : null,
    );
  }
}
