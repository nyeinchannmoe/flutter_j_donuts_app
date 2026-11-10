import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/extensions/failure_localization.dart';
import 'package:jdonuts/core/utils/clock.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/core/widgets/scaffold/step_page_scaffold.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/registration_date_of_birth/widgets/month_picker_sheet.dart';
import 'package:jdonuts/module/auth/presentation/screens/registration_date_of_birth/widgets/registration_dob_fields.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_legal_footer.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_progress.dart';

/// Final registration step. Submitting stores the member and starts a
/// session; [onRegistered] replaces the stack with Welcome.
class RegistrationDateOfBirthScreen extends StatefulWidget {
  const RegistrationDateOfBirthScreen({
    required this.onRegistered,
    required this.clock,
    super.key,
  });

  final VoidCallback onRegistered;
  final Clock clock;

  @override
  State<RegistrationDateOfBirthScreen> createState() =>
      _RegistrationDateOfBirthScreenState();
}

class _RegistrationDateOfBirthScreenState
    extends State<RegistrationDateOfBirthScreen> {
  late final TextEditingController _month;
  late final TextEditingController _day;
  late final TextEditingController _year;
  late final FocusNode _monthFocus = FocusNode();
  late final FocusNode _dayFocus = FocusNode();
  late final FocusNode _yearFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final draft = context.read<RegistrationBloc>().state;
    _month = TextEditingController(text: _monthText(draft.month));
    _day = TextEditingController(text: draft.dayText);
    _year = TextEditingController(text: draft.yearText);
  }

  @override
  void dispose() {
    _month.dispose();
    _day.dispose();
    _year.dispose();
    _monthFocus.dispose();
    _dayFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  String _monthText(int? month) {
    if (month == null) return '';
    return monthLabel(month, context.l10n.localeName);
  }

  void _syncControllers(RegistrationState state) {
    final nextMonth = _monthText(state.month);
    if (_month.text != nextMonth) {
      _month.value = TextEditingValue(
        text: nextMonth,
        selection: TextSelection.collapsed(offset: nextMonth.length),
      );
    }
    _writeIfChanged(_day, state.dayText);
    _writeIfChanged(_year, state.yearText);
  }

  void _writeIfChanged(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: _listeners,
    child: StepPageScaffold(
      title: context.l10n.dobTitle,
      onBack: () => Navigator.maybePop(context),
      progress: const AuthStepProgress(step: 4, completed: true),
      content: RegistrationDobFields(
        monthController: _month,
        dayController: _day,
        yearController: _year,
        monthFocus: _monthFocus,
        dayFocus: _dayFocus,
        yearFocus: _yearFocus,
        clock: widget.clock,
      ),
      action: _ContinueAction(clock: widget.clock),
      supportingContent: const AuthLegalFooter(),
    ),
  );

  List<BlocListener<RegistrationBloc, RegistrationState>> get _listeners => [
    _dayFocusListener(),
    _draftSyncListener(),
    _completedListener(),
    _failureListener(),
  ];

  BlocListener<RegistrationBloc, RegistrationState> _dayFocusListener() =>
      BlocListener(
        listenWhen: (previous, current) =>
            previous.dayFocusToken != current.dayFocusToken,
        listener: (context, state) {
          _syncControllers(state);
          _dayFocus.requestFocus();
        },
      );

  BlocListener<RegistrationBloc, RegistrationState> _draftSyncListener() =>
      BlocListener(
        listenWhen: (previous, current) =>
            previous.month != current.month ||
            previous.dayText != current.dayText ||
            previous.yearText != current.yearText,
        listener: (context, state) => _syncControllers(state),
      );

  BlocListener<RegistrationBloc, RegistrationState> _completedListener() =>
      BlocListener(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == RegistrationStatus.completed,
        listener: (context, state) => widget.onRegistered(),
      );

  BlocListener<RegistrationBloc, RegistrationState> _failureListener() =>
      BlocListener(
        listenWhen: (previous, current) =>
            current.failure != null && previous.failure != current.failure,
        listener: (context, state) {
          final failure = state.failure;
          if (failure == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.localizedMessage(context.l10n))),
          );
        },
      );
}

class _ContinueAction extends StatelessWidget {
  const _ContinueAction({required this.clock});

  final Clock clock;

  @override
  Widget build(BuildContext context) {
    final today = clock.now();
    final (enabled, busy) = context.select<RegistrationBloc, (bool, bool)>(
      (bloc) => (
        bloc.state.canSubmit(today),
        bloc.state.status == RegistrationStatus.submitting,
      ),
    );
    return AppButton(
      label: context.l10n.actionContinue,
      isLoading: busy,
      usePrimaryDisabledFill: true,
      onPressed: enabled
          ? () => context.read<RegistrationBloc>().add(
              const RegistrationSubmitted(),
            )
          : null,
    );
  }
}
