import 'dart:convert';

import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/storage/secure_key_value_store.dart';
import 'package:jdonuts/core/storage/stored_session.dart';

/// Persists the signed-in session in secure storage.
///
/// A read error or a corrupt record is logged and treated as signed out,
/// so a keychain problem can never trap the user on a broken session.
class SessionStore {
  SessionStore({required this._store, required this._logger});

  static const String sessionKey = 'jdonuts.session.v1';

  final SecureKeyValueStore _store;
  final AppLogger _logger;

  Future<StoredSession?> read() async {
    try {
      final raw = await _store.read(sessionKey);
      if (raw == null) return null;
      return StoredSession.fromJson(jsonDecode(raw) as Map<String, Object?>);
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Session read failed; treating as signed out',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> write(StoredSession session) =>
      _store.write(sessionKey, jsonEncode(session.toJson()));

  Future<void> clear() => _store.delete(sessionKey);
}
