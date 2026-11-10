import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/extensions/failure_localization.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/core/widgets/inputs/prefixed_text_field.dart';
import 'package:jdonuts/core/widgets/scaffold/step_page_scaffold.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/presentation/bloc/phone_entry/phone_entry_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/phone_entry/widgets/account_missing_message.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_legal_footer.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_progress.dart';

class PhoneEntryScreen extends StatelessWidget {
  const PhoneEntryScreen({
    required this.onCodeSent,
    this.onSwitchToRegister,
    this.initialNationalDigits,
    super.key,
  });

  final ValueChanged<String> onCodeSent;
  final ValueChanged<String>? onSwitchToRegister;
  final String? initialNationalDigits;

  @override
  Widget build(BuildContext context) =>
      BlocListener<PhoneEntryBloc, PhoneEntryState>(
        listenWhen: (previous, current) =>
            !previous.codeSent && current.codeSent,
        listener: (context, state) => onCodeSent(state.phoneE164!),
        child: StepPageScaffold(
          title: context.l10n.phoneTitle,
          onBack: () => Navigator.maybePop(context),
          progress: const AuthStepProgress(step: 1),
          content: _PhoneInput(
            initialNationalDigits: initialNationalDigits,
            onSwitchToRegister: onSwitchToRegister,
          ),
          action: const _ContinueAction(),
          supportingContent: const AuthLegalFooter(),
        ),
      );
}

class _PhoneInput extends StatefulWidget {
  const _PhoneInput({
    this.initialNationalDigits,
    this.onSwitchToRegister,
  });

  final String? initialNationalDigits;
  final ValueChanged<String>? onSwitchToRegister;

  @override
  State<_PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<_PhoneInput> {
  static const _maxLength = 20;
  static final List<TextInputFormatter> _formatters = [
    FilteringTextInputFormatter.allow(RegExp('[0-9 -]')),
    LengthLimitingTextInputFormatter(_maxLength),
  ];

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialNationalDigits ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.select<PhoneEntryBloc, PhoneEntryState>(
      (bloc) => bloc.state,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(context, state),
        if (state.accountMissing) _missingLink(state),
      ],
    );
  }

  Widget _field(BuildContext context, PhoneEntryState state) {
    final bloc = context.read<PhoneEntryBloc>();
    final l10n = context.l10n;
    return PrefixedTextField(
      label: l10n.phoneFieldLabel,
      prefix: l10n.phoneCountryPrefix,
      controller: _controller,
      errorText: _errorText(state, context.l10n),
      hasError: state.accountMissing,
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

  String? _errorText(PhoneEntryState state, AppLocalizations l10n) {
    if (state.accountMissing) return null;
    if (state.showInvalid) return l10n.phoneInvalid;
    return state.failure?.localizedMessage(l10n);
  }

  Widget _missingLink(PhoneEntryState state) {
    final phone = state.phoneE164;
    final onRegister = widget.onSwitchToRegister;
    if (phone == null || onRegister == null) return const SizedBox.shrink();
    return AccountMissingMessage(onRegister: () => onRegister(phone));
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
