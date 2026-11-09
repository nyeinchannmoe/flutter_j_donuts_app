import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/seed/catalog_import_runner.dart';
import 'package:jdonuts/core/database/unit_of_work.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/network/remote_data_source.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/sync/sync_coordinator.dart';
import 'package:jdonuts/core/sync/sync_policy.dart';
import 'package:jdonuts/core/sync/sync_status.dart';

import '../../helpers/fake_clock.dart';
import '../../helpers/seed_harness.dart';
import '../../helpers/test_database.dart';
import '../../helpers/test_doubles.dart';

/// Remote whose responses the test completes by hand.
class _ControlledRemote implements RemoteDataSource {
  final List<Completer<Result<CatalogPayload>>> requests = [];

  @override
  Future<Result<CatalogPayload>> fetchCatalog() {
    final request = Completer<Result<CatalogPayload>>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late FakeClock clock;

  setUp(() async {
    database = openTestDatabase();
    clock = FakeClock(DateTime(2026, 11, 9, 9));
    await seedServiceFor(database).ensureSeeded();
  });
  tearDown(() => database.close());

  SyncCoordinator buildCoordinator(RemoteDataSource remote) {
    final coordinator = SyncCoordinator(
      remote: remote,
      runner: catalogRunnerFor(database),
      unitOfWork: DriftUnitOfWork(database),
      appMetaDao: database.appMetaDao,
      logger: silentLogger(),
      clock: clock,
    );
    addTearDown(coordinator.dispose);
    return coordinator;
  }

  group('SyncCoordinator', () {
    test('concurrent requests share one fetch', () async {
      final remote = _ControlledRemote();
      final coordinator = buildCoordinator(remote);

      final first = coordinator.requestSync(SyncTrigger.appStart);
      final second = coordinator.requestSync(SyncTrigger.pullToRefresh);
      await pumpEventQueue();
      remote.requests.single.complete(const Ok({}));

      expect(await first, same(await second));
      expect(remote.requests, hasLength(1));
    });

    test('automatic syncs inside the TTL are skipped', () async {
      final coordinator = buildCoordinator(const NoopRemoteDataSource());
      await coordinator.requestSync(SyncTrigger.appStart);
      clock.advance(const Duration(minutes: 5));

      final result = await coordinator.requestSync(SyncTrigger.appResume);

      expect(result.valueOrNull, isA<SyncSkipped>());
    });

    test('pull to refresh ignores the TTL', () async {
      final coordinator = buildCoordinator(const NoopRemoteDataSource());
      await coordinator.requestSync(SyncTrigger.appStart);

      final result = await coordinator.requestSync(SyncTrigger.pullToRefresh);

      expect(result.valueOrNull, isA<SyncSucceeded>());
    });

    test('an empty remote payload keeps the seeded catalog', () async {
      final before = await database.select(database.banners).get();

      await buildCoordinator(
        const NoopRemoteDataSource(),
      ).requestSync(SyncTrigger.appStart);

      expect(await database.select(database.banners).get(), before);
      expect(await database.select(database.products).get(), isNotEmpty);
    });

    test('a failed fetch reports failure and keeps cached data', () async {
      final remote = _ControlledRemote();
      final coordinator = buildCoordinator(remote);
      final statuses = <SyncStatus>[];
      coordinator.status.listen(statuses.add);

      final pending = coordinator.requestSync(SyncTrigger.appStart);
      await pumpEventQueue();
      remote.requests.single.complete(const Err(NetworkFailure()));
      final result = await pending;
      await pumpEventQueue();

      expect(result.failureOrNull, const NetworkFailure());
      expect(coordinator.currentStatus, isA<SyncFailed>());
      expect(statuses, [isA<SyncInProgress>(), isA<SyncFailed>()]);
      expect(await database.select(database.products).get(), isNotEmpty);
    });
  });
}
