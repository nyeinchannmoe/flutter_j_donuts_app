import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/core/widgets/inputs/app_text_field.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_scaffold.dart';

/// Name step. Fields start from the shared registration draft so going
/// back from the date of birth step keeps what was typed.
class RegistrationNameScreen extends StatefulWidget {
  const RegistrationNameScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  State<RegistrationNameScreen> createState() => _RegistrationNameScreenState();
}

class _RegistrationNameScreenState extends State<RegistrationNameScreen> {
  late final RegistrationState _draft = context.read<RegistrationBloc>().state;
  late final TextEditingController _firstName = TextEditingController(
    text: _draft.firstName,
  );
  late final TextEditingController _lastName = TextEditingController(
    text: _draft.lastName,
  );

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  void _onChanged(String _) => context.read<RegistrationBloc>().add(
    RegistrationNameChanged(
      firstName: _firstName.text,
      lastName: _lastName.text,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AuthStepScaffold(
      step: 3,
      title: l10n.nameTitle,
      action: BlocSelector<RegistrationBloc, RegistrationState, bool>(
        selector: (state) => state.hasName,
        builder: (context, hasName) => AppButton(
          label: l10n.actionContinue,
          onPressed: hasName ? widget.onContinue : null,
        ),
      ),
      child: _fields(context),
    );
  }

  Widget _fields(BuildContext context) => Column(
    spacing: context.spacing.lg,
    children: [
      AppTextField(
        controller: _firstName,
        label: context.l10n.firstNameLabel,
        autofocus: true,
        autofillHints: const [AutofillHints.givenName],
        textInputAction: TextInputAction.next,
        onChanged: _onChanged,
      ),
      AppTextField(
        controller: _lastName,
        label: context.l10n.lastNameLabel,
        autofillHints: const [AutofillHints.familyName],
        textInputAction: TextInputAction.done,
        onChanged: _onChanged,
      ),
    ],
  );
}
