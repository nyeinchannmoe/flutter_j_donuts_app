import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/core/widgets/scaffold/step_page_scaffold.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/registration_name/widgets/registration_name_fields.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_legal_footer.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_progress.dart';

/// Name step. Fields start from the shared registration draft so going
/// back from the date of birth step keeps what was typed.
class RegistrationNameScreen extends StatefulWidget {
  const RegistrationNameScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  State<RegistrationNameScreen> createState() => _RegistrationNameScreenState();
}

class _RegistrationNameScreenState extends State<RegistrationNameScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final FocusNode _firstFocus = FocusNode();
  late final FocusNode _lastFocus = FocusNode();

  static final List<TextInputFormatter> _limiters = [
    LengthLimitingTextInputFormatter(AuthValidators.personNameInputLimit),
  ];

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegistrationBloc>().state;
    _firstName = TextEditingController(text: draft.firstName);
    _lastName = TextEditingController(text: draft.lastName);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _firstFocus.dispose();
    _lastFocus.dispose();
    super.dispose();
  }

  void _syncControllers(RegistrationState state) {
    _writeIfChanged(_firstName, state.firstName);
    _writeIfChanged(_lastName, state.lastName);
  }

  void _writeIfChanged(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<RegistrationBloc, RegistrationState>(
        listenWhen: (previous, current) =>
            previous.nameAdvanceToken != current.nameAdvanceToken,
        listener: (context, state) {
          _syncControllers(state);
          widget.onContinue();
        },
        child: StepPageScaffold(
          title: context.l10n.nameTitle,
          onBack: () => Navigator.maybePop(context),
          progress: const AuthStepProgress(step: 3),
          content: RegistrationNameFields(
            firstName: _firstName,
            lastName: _lastName,
            firstFocus: _firstFocus,
            lastFocus: _lastFocus,
            limiters: _limiters,
          ),
          action: const _ContinueAction(),
          supportingContent: const AuthLegalFooter(),
        ),
      );
}

class _ContinueAction extends StatelessWidget {
  const _ContinueAction();

  @override
  Widget build(BuildContext context) {
    final (enabled, busy) = context.select<RegistrationBloc, (bool, bool)>(
      (bloc) => (bloc.state.canContinueName, bloc.state.nameSubmitting),
    );
    return AppButton(
      label: context.l10n.actionContinue,
      isLoading: busy,
      usePrimaryDisabledFill: true,
      onPressed: enabled
          ? () => context.read<RegistrationBloc>().add(
              const RegistrationNameSubmitted(),
            )
          : null,
    );
  }
}
