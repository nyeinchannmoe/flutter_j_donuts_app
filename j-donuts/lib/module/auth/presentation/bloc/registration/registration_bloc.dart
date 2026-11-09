import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/usecases/register_user.dart';
import 'package:jdonuts/module/auth/domain/validators/auth_validators.dart';

part 'registration_bloc.freezed.dart';
part 'registration_event.dart';
part 'registration_state.dart';

/// Holds the registration draft across the name and date of birth steps
/// so back navigation keeps what was entered.
class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc({required this._registerUser})
    : super(const RegistrationState()) {
    on<RegistrationNameChanged>(_onNameChanged, transformer: sequential());
    on<RegistrationDateOfBirthChanged>(
      _onDateOfBirthChanged,
      transformer: sequential(),
    );
    on<RegistrationSubmitted>(_onSubmitted, transformer: droppable());
  }

  final RegisterUser _registerUser;

  void _onNameChanged(
    RegistrationNameChanged event,
    Emitter<RegistrationState> emit,
  ) => emit(
    state.copyWith(
      firstName: event.firstName,
      lastName: event.lastName,
      status: RegistrationStatus.editing,
    ),
  );

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
    final result = await _registerUser(
      RegistrationDetails(
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim().isEmpty ? null : state.lastName.trim(),
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
