import 'package:drift/drift.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/module/auth/domain/entities/registration_details.dart';
import 'package:jdonuts/module/auth/domain/entities/user_profile.dart';

extension LocalUserRowMapper on LocalUserRow {
  UserProfile toEntity() => UserProfile(
    id: id,
    phoneE164: phoneE164,
    firstName: firstName,
    lastName: lastName,
    dateOfBirth: dateOfBirth,
  );
}

extension RegistrationDetailsMapper on RegistrationDetails {
  LocalUsersCompanion toCompanion({
    required String id,
    required String phoneE164,
    required DateTime createdAt,
  }) => LocalUsersCompanion.insert(
    id: id,
    phoneE164: phoneE164,
    firstName: firstName,
    lastName: Value(lastName),
    dateOfBirth: dateOfBirth,
    createdAt: createdAt,
  );
}
