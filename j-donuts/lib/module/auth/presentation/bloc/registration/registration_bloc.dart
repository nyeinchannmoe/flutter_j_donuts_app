import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/utils/clock.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/usecases/register_user.dart';
import 'package:jdonuts/module/auth/domain/usecases/save_registration_name.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';
import 'package:jdonuts/module/auth/domain/validators/date_of_birth_validator.dart';

part 'registration_bloc.freezed.dart';
part 'registration_event.dart';
part 'registration_state.dart';

/// Holds the registration draft across the name and date of birth steps
/// so back navigation keeps what was entered.
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc({
    required this._saveRegistrationName,
    required this._registerUser,
    required this._clock,
  }) : super(const RegistrationState()) {
    on<RegistrationFirstNameChanged>(
      _onFirstNameChanged,
      transformer: sequential(),
    );
    on<RegistrationLastNameChanged>(
      _onLastNameChanged,
      transformer: sequential(),
    );
    on<RegistrationFirstNameFocusChanged>(_onFirstNameFocusChanged);
    on<RegistrationLastNameFocusChanged>(_onLastNameFocusChanged);
    on<RegistrationNameSubmitted>(
      _onNameSubmitted,
      transformer: droppable(),
    );
    on<RegistrationMonthSelected>(
      _onMonthSelected,
      transformer: sequential(),
    );
    on<RegistrationDayChanged>(_onDayChanged, transformer: sequential());
    on<RegistrationYearChanged>(_onYearChanged, transformer: sequential());
    on<RegistrationMonthFocusChanged>(_onMonthFocusChanged);
    on<RegistrationDayFocusChanged>(_onDayFocusChanged);
    on<RegistrationYearFocusChanged>(_onYearFocusChanged);
    on<RegistrationSubmitted>(_onSubmitted, transformer: droppable());
  }

  final SaveRegistrationName _saveRegistrationName;
  final RegisterUser _registerUser;
  final Clock _clock;

  void _onFirstNameChanged(
    RegistrationFirstNameChanged event,
    Emitter<RegistrationState> emit,
  ) {
    if (state.nameSubmitting) return;
    emit(
      state.copyWith(
        firstName: event.value,
        status: RegistrationStatus.editing,
        failure: null,
      ),
    );
  }

  void _onLastNameChanged(
    RegistrationLastNameChanged event,
    Emitter<RegistrationState> emit,
  ) {
    if (state.nameSubmitting) return;
    emit(
      state.copyWith(
        lastName: event.value,
        status: RegistrationStatus.editing,
        failure: null,
      ),
    );
  }

  void _onFirstNameFocusChanged(
    RegistrationFirstNameFocusChanged event,
    Emitter<RegistrationState> emit,
  ) {
    if (event.focused) return;
    emit(state.copyWith(firstNameTouched: true));
  }

  void _onLastNameFocusChanged(
    RegistrationLastNameFocusChanged event,
    Emitter<RegistrationState> emit,
  ) {
    if (event.focused) return;
    emit(state.copyWith(lastNameTouched: true));
  }

  Future<void> _onNameSubmitted(
    RegistrationNameSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(
      state.copyWith(
        firstNameTouched: true,
        lastNameTouched: true,
        failure: null,
      ),
    );
    if (!state.canContinueName) return;
    emit(state.copyWith(nameSubmitting: true));
    final result = await _saveRegistrationName(
      firstName: state.firstName,
      lastName: state.lastName,
    );
    final first = AuthValidators.normalizePersonName(state.firstName);
    final last = AuthValidators.normalizePersonName(state.lastName);
    emit(switch (result) {
      Ok() => state.copyWith(
        firstName: first,
        lastName: last,
        nameSubmitting: false,
        nameAdvanceToken: state.nameAdvanceToken + 1,
      ),
      Err(:final failure) => state.copyWith(
        nameSubmitting: false,
        failure: failure,
      ),
    });
  }

  void _onMonthSelected(
    RegistrationMonthSelected event,
    Emitter<RegistrationState> emit,
  ) {
    if (state.status == RegistrationStatus.submitting) return;
    emit(
      state.copyWith(
        month: event.month,
        monthTouched: true,
        dayFocusToken: state.dayFocusToken + 1,
        status: RegistrationStatus.editing,
        failure: null,
      ),
    );
  }

  void _onDayChanged(
    RegistrationDayChanged event,
    Emitter<RegistrationState> emit,
  ) {
    if (state.status == RegistrationStatus.submitting) return;
    emit(
      state.copyWith(
        dayText: event.value,
        status: RegistrationStatus.editing,
        failure: null,
      ),
    );
  }

  void _onYearChanged(
    RegistrationYearChanged event,
    Emitter<RegistrationState> emit,
  ) {
    if (state.status == RegistrationStatus.submitting) return;
    emit(
      state.copyWith(
        yearText: event.value,
        status: RegistrationStatus.editing,
        failure: null,
      ),
    );
  }

  void _onMonthFocusChanged(
    RegistrationMonthFocusChanged event,
    Emitter<RegistrationState> emit,
  ) {
    if (event.focused) return;
    emit(state.copyWith(monthTouched: true));
  }

  void _onDayFocusChanged(
    RegistrationDayFocusChanged event,
    Emitter<RegistrationState> emit,
  ) {
    if (event.focused) return;
    emit(state.copyWith(dayTouched: true));
  }

  void _onYearFocusChanged(
    RegistrationYearFocusChanged event,
    Emitter<RegistrationState> emit,
  ) {
    if (event.focused) return;
    emit(state.copyWith(yearTouched: true));
  }

  Future<void> _onSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    final today = _clock.now();
    emit(
      state.copyWith(
        monthTouched: true,
        dayTouched: true,
        yearTouched: true,
        failure: null,
      ),
    );
    final dateOfBirth = state.resolvedDateOfBirth(today);
    if (dateOfBirth == null) return;
    emit(state.copyWith(status: RegistrationStatus.submitting, failure: null));
    final first = AuthValidators.normalizePersonName(state.firstName);
    final last = AuthValidators.normalizePersonName(state.lastName);
    final result = await _registerUser(
      RegistrationDetails(
        firstName: first,
        lastName: last.isEmpty ? null : last,
        dateOfBirth: dateOfBirth,
      ),
    );
    emit(switch (result) {
      Ok() => state.copyWith(status: RegistrationStatus.completed),
      Err(:final failure) => state.copyWith(
        status: RegistrationStatus.failed,
        failure: failure,
      ),
    });
  }
}
