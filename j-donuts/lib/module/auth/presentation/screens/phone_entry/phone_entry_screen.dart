import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/extensions/failure_localization.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/core/widgets/inputs/app_text_field.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/presentation/bloc/phone_entry/phone_entry_bloc.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_scaffold.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({required this.onCodeSent, super.key});

  final ValueChanged<String> onCodeSent;

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String? phoneE164) {
    if (phoneE164 == null) return;
    context.read<PhoneEntryBloc>().add(PhoneEntrySubmitted(phoneE164));
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<PhoneEntryBloc, PhoneEntryState>(
        listenWhen: (previous, current) => current is PhoneEntryCodeSent,
        listener: (context, state) {
          if (state is PhoneEntryCodeSent) widget.onCodeSent(state.phoneE164);
        },
        builder: (context, state) => _PhoneStep(
          state: state,
          controller: _controller,
          onSubmit: _submit,
        ),
      );
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({
    required this.state,
    required this.controller,
    required this.onSubmit,
  });

  final PhoneEntryState state;
  final TextEditingController controller;
  final ValueChanged<String?> onSubmit;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final phoneE164 = AuthValidators.toMyanmarE164(value.text);
          return AuthStepScaffold(
            step: 1,
            title: context.l10n.phoneTitle,
            action: AppButton(
              label: context.l10n.actionContinue,
              isLoading: state is PhoneEntrySubmitting,
              onPressed: phoneE164 == null ? null : () => onSubmit(phoneE164),
            ),
            child: _PhoneField(
              controller: controller,
              errorText: switch (state) {
                PhoneEntryFailure(:final failure) => failure.localizedMessage(
                  context.l10n,
                ),
                _ => null,
              },
              onSubmitted: () => onSubmit(phoneE164),
            ),
          );
        },
      );
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.errorText,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) => AppTextField(
    controller: controller,
    label: context.l10n.phoneFieldLabel,
    prefixText: context.l10n.phoneCountryPrefix,
    errorText: errorText,
    autofocus: true,
    keyboardType: TextInputType.phone,
    textInputAction: TextInputAction.done,
    autofillHints: const [AutofillHints.telephoneNumberNational],
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    onSubmitted: (_) => onSubmitted(),
  );
}
