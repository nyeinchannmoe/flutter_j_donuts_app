import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/utils/clock.dart';
import 'package:jdonuts/core/widgets/inputs/filled_text_field.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/domain/validators/date_of_birth_validator.dart';
import 'package:jdonuts/module/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/registration_date_of_birth/widgets/month_picker_sheet.dart';

class RegistrationDobFields extends StatelessWidget {
  const RegistrationDobFields({
    required this.monthController,
    required this.dayController,
    required this.yearController,
    required this.monthFocus,
    required this.dayFocus,
    required this.yearFocus,
    required this.clock,
    super.key,
  });

  static const int dayMaxLength = 2;

  final TextEditingController monthController;
  final TextEditingController dayController;
  final TextEditingController yearController;
  final FocusNode monthFocus;
  final FocusNode dayFocus;
  final FocusNode yearFocus;
  final Clock clock;

  static final List<TextInputFormatter> dayFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(dayMaxLength),
  ];

  static final List<TextInputFormatter> yearFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(DateOfBirthValidator.yearDigitCount),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = clock.now();
    final slice = context.select<RegistrationBloc, _DobSlice>(
      (bloc) => _DobSlice(
        month: bloc.state.month,
        errorCode: bloc.state.dobErrorCode(today),
        busy: bloc.state.status == RegistrationStatus.submitting,
      ),
    );
    final errorText = messageFor(l10n, slice.errorCode);
    final invalid = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledTextField(
          controller: monthController,
          focusNode: monthFocus,
          label: l10n.dobMonthLabel,
          hasError: invalid,
          readOnly: true,
          showCursor: false,
          enableInteractiveSelection: false,
          onTap: slice.busy
              ? null
              : () => _pickMonth(context, slice.month),
          onFocusChanged: (focused) => context.read<RegistrationBloc>().add(
            RegistrationMonthFocusChanged(focused: focused),
          ),
        ),
        SizedBox(height: context.spacing.md),
        FilledTextField(
          controller: dayController,
          focusNode: dayFocus,
          label: l10n.dobDayLabel,
          hasError: invalid,
          readOnly: slice.busy,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          autofillHints: const [AutofillHints.birthdayDay],
          inputFormatters: dayFormatters,
          onChanged: (value) => context.read<RegistrationBloc>().add(
            RegistrationDayChanged(value),
          ),
          onFocusChanged: (focused) => context.read<RegistrationBloc>().add(
            RegistrationDayFocusChanged(focused: focused),
          ),
          onSubmitted: (_) => yearFocus.requestFocus(),
        ),
        SizedBox(height: context.spacing.md),
        FilledTextField(
          controller: yearController,
          focusNode: yearFocus,
          label: l10n.dobYearLabel,
          hasError: invalid,
          readOnly: slice.busy,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          autofillHints: const [AutofillHints.birthdayYear],
          inputFormatters: yearFormatters,
          onChanged: (value) => context.read<RegistrationBloc>().add(
            RegistrationYearChanged(value),
          ),
          onFocusChanged: (focused) => context.read<RegistrationBloc>().add(
            RegistrationYearFocusChanged(focused: focused),
          ),
          onSubmitted: (_) => context.read<RegistrationBloc>().add(
            const RegistrationSubmitted(),
          ),
        ),
        _DobErrorMessage(message: errorText),
      ],
    );
  }

  Future<void> _pickMonth(BuildContext context, int? selected) async {
    final l10n = context.l10n;
    final month = await showMonthPickerSheet(
      context: context,
      selectedMonth: selected,
      title: l10n.dobMonthSheetTitle,
    );
    if (month == null || !context.mounted) return;
    context.read<RegistrationBloc>().add(RegistrationMonthSelected(month));
  }

  static String? messageFor(AppLocalizations l10n, String? code) =>
      switch (code) {
        AuthValidators.dobNotRealCode => l10n.dobErrorNotReal,
        AuthValidators.dobFutureCode => l10n.dobErrorFuture,
        AuthValidators.dobTooYoungCode => l10n.dobErrorTooYoung,
        _ => null,
      };
}

class _DobSlice {
  const _DobSlice({
    required this.month,
    required this.errorCode,
    required this.busy,
  });

  final int? month;
  final String? errorCode;
  final bool busy;
}

class _DobErrorMessage extends StatelessWidget {
  const _DobErrorMessage({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : context.motion.scaleDuration(MotionTokens.fast);
    final child = message == null
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.only(top: context.spacing.xs),
            child: Semantics(
              liveRegion: true,
              child: Text(
                message!,
                style: context.typography.caption.copyWith(
                  color: context.colors.danger,
                ),
              ),
            ),
          );
    if (reduceMotion) return child;
    return AnimatedSize(
      duration: duration,
      curve: MotionTokens.standardCurve,
      alignment: Alignment.topLeft,
      child: child,
    );
  }
}
