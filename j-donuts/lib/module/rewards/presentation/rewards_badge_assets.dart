/// Bundled shield artwork keyed by catalog tier id.
abstract final class RewardsBadgeAssets {
  static const String silver = 'assets/images/rewards/tier_shield_silver.webp';
  static const String gold = 'assets/images/rewards/tier_shield_gold.webp';
  static const String platinum =
      'assets/images/rewards/tier_shield_platinum.webp';

  static String? forTierId(String tierId) => switch (tierId) {
    't_silver' => silver,
    't_gold' => gold,
    't_platinum' => platinum,
    _ => null,
  };
}
