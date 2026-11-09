/// Why a sync was requested.
enum SyncTrigger {
  appStart,
  appResume,
  reconnected,
  pullToRefresh;

  /// Manual refreshes always run; automatic ones respect the TTL.
  bool get bypassesTtl => this == pullToRefresh;
}

/// Freshness rules for catalog refreshes.
class SyncPolicy {
  const SyncPolicy({this.catalogTtl = defaultCatalogTtl});

  static const Duration defaultCatalogTtl = Duration(minutes: 15);
  static const String catalogScope = 'catalog';

  final Duration catalogTtl;

  bool shouldSync({
    required SyncTrigger trigger,
    required DateTime? lastSyncAt,
    required DateTime now,
  }) {
    if (trigger.bypassesTtl || lastSyncAt == null) return true;
    return now.difference(lastSyncAt) >= catalogTtl;
  }
}
