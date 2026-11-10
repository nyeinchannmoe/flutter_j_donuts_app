/// Asset size budgets from docs/PERFORMANCE_BUDGET.md.
abstract final class AssetBudget {
  static const int kibibyte = 1024;
  static const int maxSeedImageBytes = 20 * kibibyte;
  static const int maxSeedImagesTotalBytes = 300 * kibibyte;
  static const int maxRewardsImageBytes = 80 * kibibyte;
  static const int maxCatalogBytes = 64 * kibibyte;
  static const int maxFontBytes = 160 * kibibyte;
  static const int maxOnboardingHeroBytes = 1700 * kibibyte;
  static const int maxWelcomeHeroBytes = 1300 * kibibyte;
  static const int maxAssetsTotalBytes = 1024 * kibibyte;

  static const String onboardingHeroPath =
      'assets/images/onboarding/onboarding_hero.png';
  static const String welcomeHeroPath =
      'assets/images/welcome/welcome_hero.png';
  static const String seedImagesDir = 'assets/seed/images/';
  static const String rewardsImagesDir = 'assets/images/rewards/';
  static const String catalogPath = 'assets/seed/catalog.json';
  static const String fontsDir = 'assets/fonts/';
  static const Set<String> allowedSeedImageExtensions = {'.webp'};
  static const Set<String> allowedRewardsImageExtensions = {'.webp'};
}

/// One asset with its path relative to the project root.
class AssetFile {
  const AssetFile({required this.path, required this.bytes});

  final String path;
  final int bytes;
}

/// Returns a message for every budget the [assets] exceed.
List<String> checkAssetBudget(List<AssetFile> assets) {
  final problems = <String>[];
  var seedTotal = 0;
  var total = 0;
  for (final asset in assets) {
    if (asset.path == AssetBudget.onboardingHeroPath) {
      problems.addAll(_limit(asset, AssetBudget.maxOnboardingHeroBytes));
      continue;
    }
    if (asset.path == AssetBudget.welcomeHeroPath) {
      problems.addAll(_limit(asset, AssetBudget.maxWelcomeHeroBytes));
      continue;
    }
    total += asset.bytes;
    if (asset.path.startsWith(AssetBudget.seedImagesDir)) {
      seedTotal += asset.bytes;
      problems.addAll(_seedImageProblems(asset));
    } else if (asset.path.startsWith(AssetBudget.rewardsImagesDir)) {
      problems.addAll(_rewardsImageProblems(asset));
    } else if (asset.path == AssetBudget.catalogPath) {
      problems.addAll(_limit(asset, AssetBudget.maxCatalogBytes));
    } else if (asset.path.startsWith(AssetBudget.fontsDir) &&
        asset.path.endsWith('.ttf')) {
      problems.addAll(_limit(asset, AssetBudget.maxFontBytes));
    }
  }
  if (seedTotal > AssetBudget.maxSeedImagesTotalBytes) {
    problems.add(
      'seed images total $seedTotal B > '
      '${AssetBudget.maxSeedImagesTotalBytes} B',
    );
  }
  if (total > AssetBudget.maxAssetsTotalBytes) {
    problems.add(
      'assets total $total B > ${AssetBudget.maxAssetsTotalBytes} B',
    );
  }
  return problems;
}

Iterable<String> _seedImageProblems(AssetFile asset) sync* {
  final dot = asset.path.lastIndexOf('.');
  final extension = dot < 0 ? '' : asset.path.substring(dot);
  if (!AssetBudget.allowedSeedImageExtensions.contains(extension)) {
    yield '${asset.path} must be WebP';
  }
  yield* _limit(asset, AssetBudget.maxSeedImageBytes);
}

Iterable<String> _rewardsImageProblems(AssetFile asset) sync* {
  final dot = asset.path.lastIndexOf('.');
  final extension = dot < 0 ? '' : asset.path.substring(dot);
  if (!AssetBudget.allowedRewardsImageExtensions.contains(extension)) {
    yield '${asset.path} must be WebP';
  }
  yield* _limit(asset, AssetBudget.maxRewardsImageBytes);
}

Iterable<String> _limit(AssetFile asset, int maxBytes) sync* {
  if (asset.bytes > maxBytes) {
    yield '${asset.path} is ${asset.bytes} B > $maxBytes B';
  }
}
