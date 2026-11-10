import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/extensions/failure_localization.dart';
import 'package:jdonuts/core/utils/date_formatter.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_scaffold.dart';

/// Final step. Submitting registers the member; the router then moves to
/// Welcome when the session becomes authenticated.
class RegistrationDateOfBirthScreen extends StatelessWidget {
  const RegistrationDateOfBirthScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<RegistrationBloc, RegistrationState>(
        builder: (context, state) => AuthStepScaffold(
          step: 4,
          completed: state.status == RegistrationStatus.completed,
          title: context.l10n.dobTitle,
          action: AppButton(
            label: context.l10n.actionContinue,
            isLoading: state.status == RegistrationStatus.submitting,
            onPressed: state.canSubmit
                ? () => context.read<RegistrationBloc>().add(
                    const RegistrationSubmitted(),
                  )
                : null,
          ),
          child: _DateOfBirthField(state: state),
        ),
      );
}

class _DateOfBirthField extends StatelessWidget {
  const _DateOfBirthField({required this.state});

  final RegistrationState state;

  Future<void> _pick(BuildContext context) async {
    final bloc = context.read<RegistrationBloc>();
    final today = DateTime.now();
    final latest = AuthValidators.latestDateOfBirth(today);
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dateOfBirth ?? latest,
      firstDate: AuthValidators.earliestDateOfBirth(),
      lastDate: latest,
    );
    if (picked != null) bloc.add(RegistrationDateOfBirthChanged(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateOfBirth = state.dateOfBirth;
    final failure = state.failure;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.spacing.md,
      children: [
        OutlinedButton.icon(
          onPressed: () => _pick(context),
          icon: const Icon(Icons.cake_outlined),
          label: Text(
            dateOfBirth == null
                ? l10n.dobPickAction
                : DateFormatter.longDate(dateOfBirth, l10n.localeName),
            style: context.typography.subtitle,
          ),
        ),
        if (failure != null)
          Text(
            failure.localizedMessage(l10n),
            style: context.typography.label.copyWith(
              color: context.colors.danger,
            ),
          ),
      ],
    );
  }
}
