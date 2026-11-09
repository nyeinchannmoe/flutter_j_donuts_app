import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/database/app_database.dart';
import 'package:jdonuts/core/database/daos/app_meta_dao.dart';
import 'package:jdonuts/core/database/seed/seed_bundle_loader.dart';
import 'package:jdonuts/core/database/seed/seed_service.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';

import '../../helpers/seed_harness.dart';
import '../../helpers/test_database.dart';

class _CorruptBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList('{"products": 42}'.codeUnits));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  group('SeedService', () {
    test('imports the bundled catalog on first launch', () async {
      final result = await seedServiceFor(database).ensureSeeded();

      expect(result, const Ok(SeedOutcome.seeded));
      expect(await database.select(database.products).get(), isNotEmpty);
      expect(await database.select(database.tiers).get(), isNotEmpty);
      expect(await database.select(database.banners).get(), isNotEmpty);
      expect(
        await database.select(database.memberProfiles).get(),
        hasLength(1),
      );
    });

    test('skips all work when the stored version matches', () async {
      await seedServiceFor(database).ensureSeeded();

      final second = await seedServiceFor(database).ensureSeeded();

      expect(second, const Ok(SeedOutcome.alreadyCurrent));
    });

    test('a new seed version keeps cart rows', () async {
      await seedServiceFor(database).ensureSeeded();
      final product = (await database.select(database.products).get()).first;
      await database.cartDao.addQuantity(
        productId: product.id,
        quantity: 2,
        now: DateTime(2026),
      );

      final result = await seedServiceFor(
        database,
        version: SeedService.seedVersion + 1,
      ).ensureSeeded();

      expect(result, const Ok(SeedOutcome.seeded));
      final cart = await database.select(database.cartItems).get();
      expect(cart.single.quantity, 2);
    });

    test('a corrupt catalog fails without writing the version', () async {
      final service = seedServiceFor(
        database,
        loader: SeedBundleLoader(_CorruptBundle()),
      );

      final result = await service.ensureSeeded();

      expect(result.failureOrNull, isA<StorageFailure>());
      expect(
        await database.appMetaDao.readValue(AppMetaKeys.seedVersion),
        isNull,
      );
      expect(await database.select(database.products).get(), isEmpty);
    });
  });
}
