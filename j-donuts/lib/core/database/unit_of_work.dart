import 'package:jdonuts/core/database/app_database.dart';

/// Runs a group of writes atomically.
abstract interface class UnitOfWork {
  Future<T> run<T>(Future<T> Function() work);
}

/// Unit of work backed by a Drift transaction. Every DAO call made inside
/// [run] joins the same transaction through Drift's zone handling.
class DriftUnitOfWork implements UnitOfWork {
  const DriftUnitOfWork(this._database);

  final AppDatabase _database;

  @override
  Future<T> run<T>(Future<T> Function() work) => _database.transaction(work);
}
