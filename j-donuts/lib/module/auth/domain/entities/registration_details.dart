import 'package:freezed_annotation/freezed_annotation.dart';

part 'registration_details.freezed.dart';

/// Profile data collected by the registration steps.
@freezed
abstract class RegistrationDetails with _$RegistrationDetails {
  const factory RegistrationDetails({
    required String firstName,
    required DateTime dateOfBirth,
    String? lastName,
  }) = _RegistrationDetails;
}
