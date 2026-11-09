import 'package:jdonuts/core/database/seed/catalog_importer.dart';

/// Decoded catalog payload keyed by section.
typedef CatalogPayload = Map<String, Object?>;

/// Dispatches each payload section to the importer that owns it.
///
/// The runner does not open a transaction itself; callers wrap it in a
/// UnitOfWork so they can add their own bookkeeping writes atomically.
class CatalogImportRunner {
  CatalogImportRunner(List<CatalogImporter> importers)
    : _importers = List<CatalogImporter>.unmodifiable(
        List<CatalogImporter>.of(importers)
          ..sort((a, b) => a.stage.index.compareTo(b.stage.index)),
      );

  final List<CatalogImporter> _importers;

  /// Imports every section present in [payload] that [source] may write and
  /// returns the keys that were written.
  Future<List<String>> importAll(
    CatalogPayload payload, {
    required ImportSource source,
  }) async {
    final written = <String>[];
    for (final importer in _importers) {
      if (!payload.containsKey(importer.sectionKey)) continue;
      if (source == ImportSource.remote && !importer.acceptsRemoteUpdates) {
        continue;
      }
      await importer.importSection(payload[importer.sectionKey]);
      written.add(importer.sectionKey);
    }
    return written;
  }
}
