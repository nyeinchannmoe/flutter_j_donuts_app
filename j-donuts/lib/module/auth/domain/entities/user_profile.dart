import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String phoneE164,
    required String firstName,
    required DateTime dateOfBirth,
    String? lastName,
  }) = _UserProfile;
}
