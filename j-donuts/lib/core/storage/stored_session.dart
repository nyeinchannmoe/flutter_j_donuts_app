import 'package:json_annotation/json_annotation.dart';

part 'stored_session.g.dart';

/// Session record persisted in secure storage.
@JsonSerializable()
class StoredSession {
  const StoredSession({required this.userId, required this.phoneE164});

  factory StoredSession.fromJson(Map<String, Object?> json) =>
      _$StoredSessionFromJson(json);

  final String userId;
  final String phoneE164;

  Map<String, Object?> toJson() => _$StoredSessionToJson(this);
}
