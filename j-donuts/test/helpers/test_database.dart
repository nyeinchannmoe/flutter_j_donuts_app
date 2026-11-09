import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:jdonuts/core/database/app_database.dart';

/// Fresh in-memory database. Streams close synchronously so tests that
/// watch queries finish without pending timers.
AppDatabase openTestDatabase() => AppDatabase(
  DatabaseConnection(
    NativeDatabase.memory(),
    closeStreamsSynchronously: true,
  ),
);
