import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

enum SessionStatus { unknown, unauthenticated, registering, authenticated }

/// Who is using the app right now.
@freezed
sealed class Session with _$Session {
  /// Before the stored session has been read.
  const factory Session.unknown() = SessionUnknown;

  const factory Session.unauthenticated() = SessionUnauthenticated;

  /// The phone number is verified but the profile is not complete yet.
  const factory Session.registering({required String phoneE164}) =
      SessionRegistering;

  /// [isNewlyRegistered] is true only right after registration, so the
  /// router can show Welcome once.
  const factory Session.authenticated({
    required String userId,
    required String phoneE164,
    @Default(false) bool isNewlyRegistered,
  }) = SessionAuthenticated;

  const Session._();

  SessionStatus get status => switch (this) {
    SessionUnknown() => SessionStatus.unknown,
    SessionUnauthenticated() => SessionStatus.unauthenticated,
    SessionRegistering() => SessionStatus.registering,
    SessionAuthenticated() => SessionStatus.authenticated,
  };
}
