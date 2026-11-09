import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/storage/secure_key_value_store.dart';
import 'package:logger/logger.dart';

/// Logger that drops every message so test output stays readable.
AppLogger silentLogger() => AppLogger(logger: Logger(level: Level.off));

/// Secure storage replacement backed by a map.
class InMemoryKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Latency simulator that returns immediately.
Future<void> noLatency(Duration _) async {}
