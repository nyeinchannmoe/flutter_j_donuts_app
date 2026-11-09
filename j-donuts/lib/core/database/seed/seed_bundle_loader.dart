import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:jdonuts/core/database/seed/catalog_import_runner.dart';

/// Loads the bundled catalog and decodes it off the UI isolate.
class SeedBundleLoader {
  const SeedBundleLoader(this._bundle, {this.assetPath = defaultAssetPath});

  static const String defaultAssetPath = 'assets/seed/catalog.json';

  final AssetBundle _bundle;
  final String assetPath;

  Future<CatalogPayload> load() async {
    final raw = await _bundle.loadString(assetPath, cache: false);
    return Isolate.run(() => _decode(raw));
  }

  static CatalogPayload _decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Seed catalog root must be a JSON object');
    }
    return decoded;
  }
}
