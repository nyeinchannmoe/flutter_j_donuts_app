import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/usecases/register_user.dart';
import 'package:jdonuts/module/auth/domain/usecases/save_registration_name.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

part 'registration_bloc.freezed.dart';
part 'registration_event.dart';
part 'registration_state.dart';

/// Holds the registration draft across the name and date of birth steps
/// so back navigation keeps what was entered.
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc({
    required this._saveRegistrationName,
    required this._registerUser,
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
    on<RegistrationDateOfBirthChanged>(
      _onDateOfBirthChanged,
      transformer: sequential(),
    );
    on<RegistrationSubmitted>(_onSubmitted, transformer: droppable());
  }

  final SaveRegistrationName _saveRegistrationName;
  final RegisterUser _registerUser;

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

  void _onDateOfBirthChanged(
    RegistrationDateOfBirthChanged event,
    Emitter<RegistrationState> emit,
  ) => emit(
    state.copyWith(
      dateOfBirth: event.dateOfBirth,
      status: RegistrationStatus.editing,
    ),
  );

  Future<void> _onSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    final dateOfBirth = state.dateOfBirth;
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
