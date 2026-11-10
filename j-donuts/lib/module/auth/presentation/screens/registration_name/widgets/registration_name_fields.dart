import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/inputs/filled_text_field.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';

class RegistrationNameFields extends StatelessWidget {
  const RegistrationNameFields({
    required this.firstName,
    required this.lastName,
    required this.firstFocus,
    required this.lastFocus,
    required this.limiters,
    super.key,
  });

  final TextEditingController firstName;
  final TextEditingController lastName;
  final FocusNode firstFocus;
  final FocusNode lastFocus;
  final List<TextInputFormatter> limiters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final errors = context.select<RegistrationBloc, (String?, String?, bool)>(
      (b) => (
        messageFor(l10n, b.state.firstNameErrorCode),
        messageFor(l10n, b.state.lastNameErrorCode),
        b.state.nameSubmitting,
      ),
    );
    return AutofillGroup(child: _column(context, errors));
  }

  Widget _column(BuildContext context, (String?, String?, bool) errors) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FirstNameField(
            controller: firstName,
            focusNode: firstFocus,
            nextFocus: lastFocus,
            errorText: errors.$1,
            busy: errors.$3,
            limiters: limiters,
          ),
          SizedBox(height: context.spacing.md),
          _LastNameField(
            controller: lastName,
            focusNode: lastFocus,
            errorText: errors.$2,
            busy: errors.$3,
            limiters: limiters,
          ),
        ],
      );

  static String? messageFor(AppLocalizations l10n, String? code) =>
      switch (code) {
        AuthValidators.firstNameRequiredCode => l10n.firstNameRequired,
        AuthValidators.firstNameTooLongCode => l10n.firstNameTooLong,
        AuthValidators.firstNameInvalidCode => l10n.firstNameInvalid,
        AuthValidators.lastNameTooLongCode => l10n.lastNameTooLong,
        AuthValidators.lastNameInvalidCode => l10n.lastNameInvalid,
        _ => null,
      };
}

class _FirstNameField extends StatelessWidget {
  const _FirstNameField({
    required this.controller,
    required this.focusNode,
    required this.nextFocus,
    required this.errorText,
    required this.busy,
    required this.limiters,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode nextFocus;
  final String? errorText;
  final bool busy;
  final List<TextInputFormatter> limiters;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RegistrationBloc>();
    return FilledTextField(
      controller: controller,
      focusNode: focusNode,
      label: context.l10n.firstNameLabel,
      errorText: errorText,
      readOnly: busy,
      autofocus: true,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.givenName],
      inputFormatters: limiters,
      onChanged: (value) => bloc.add(RegistrationFirstNameChanged(value)),
      onFocusChanged: (focused) =>
          bloc.add(RegistrationFirstNameFocusChanged(focused: focused)),
      onSubmitted: (_) => nextFocus.requestFocus(),
    );
  }
}

class _LastNameField extends StatelessWidget {
  const _LastNameField({
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.busy,
    required this.limiters,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final bool busy;
  final List<TextInputFormatter> limiters;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RegistrationBloc>();
    return FilledTextField(
      controller: controller,
      focusNode: focusNode,
      label: context.l10n.lastNameLabel,
      errorText: errorText,
      readOnly: busy,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      autocorrect: false,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.familyName],
      inputFormatters: limiters,
      onChanged: (value) => bloc.add(RegistrationLastNameChanged(value)),
      onFocusChanged: (focused) =>
          bloc.add(RegistrationLastNameFocusChanged(focused: focused)),
      onSubmitted: (_) => bloc.add(const RegistrationNameSubmitted()),
    );
  }
}
