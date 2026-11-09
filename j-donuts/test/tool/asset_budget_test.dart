import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/asset_budget.dart';

const int _kib = AssetBudget.kibibyte;

void main() {
  group('checkAssetBudget', () {
    test('passes for assets inside every budget', () {
      final problems = checkAssetBudget(const [
        AssetFile(path: 'assets/seed/images/coconut.webp', bytes: 12 * _kib),
        AssetFile(path: 'assets/seed/catalog.json', bytes: 20 * _kib),
        AssetFile(path: 'assets/fonts/Outfit-Bold.ttf', bytes: 100 * _kib),
      ]);

      expect(problems, isEmpty);
    });

    test('rejects oversized and non-WebP seed images', () {
      final problems = checkAssetBudget(const [
        AssetFile(path: 'assets/seed/images/big.webp', bytes: 21 * _kib),
        AssetFile(path: 'assets/seed/images/photo.png', bytes: 1 * _kib),
      ]);

      expect(problems, hasLength(2));
      expect(problems.first, contains('big.webp'));
      expect(problems.last, contains('must be WebP'));
    });

    test('rejects an oversized catalog and font', () {
      final problems = checkAssetBudget(const [
        AssetFile(path: 'assets/seed/catalog.json', bytes: 65 * _kib),
        AssetFile(path: 'assets/fonts/Outfit-Bold.ttf', bytes: 161 * _kib),
      ]);

      expect(problems, hasLength(2));
    });

    test('rejects totals over the seed image and app budgets', () {
      final problems = checkAssetBudget([
        for (var i = 0; i < 16; i++)
          AssetFile(path: 'assets/seed/images/$i.webp', bytes: 19 * _kib),
        const AssetFile(path: 'assets/other.bin', bytes: 800 * _kib),
      ]);

      expect(problems, hasLength(2));
    });

    test('the bundled assets are inside every budget', () {
      final assets = Directory('assets')
          .listSync(recursive: true)
          .whereType<File>()
          .map(
            (file) => AssetFile(
              path: file.path.replaceAll(r'\', '/'),
              bytes: file.lengthSync(),
            ),
          )
          .toList();

      expect(checkAssetBudget(assets), isEmpty);
    });
  });
}
