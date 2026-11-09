/// Order in which importers run, so referenced rows exist before the rows
/// that point at them.
enum ImportStage { reference, dependent }

/// Where a catalog payload came from.
enum ImportSource { bundledSeed, remote }

/// Writes one top-level section of a catalog payload into the database.
///
/// Features implement importers for the tables they own. The same importer
/// handles the bundled seed and remote refreshes, so both paths share one
/// parser and one write strategy.
abstract interface class CatalogImporter {
  /// Top-level JSON key this importer consumes, for example `products`.
  String get sectionKey;

  ImportStage get stage;

  /// Whether a remote refresh may overwrite this section. User-owned
  /// sections such as the member record are seeded once and then owned by
  /// the device.
  bool get acceptsRemoteUpdates;

  /// Parses [json] and writes it. Throws FormatException or TypeError on a
  /// malformed payload; callers run this inside a unit of work.
  Future<void> importSection(Object? json);
}
