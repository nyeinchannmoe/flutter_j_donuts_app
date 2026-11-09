import 'dart:io';

import 'src/asset_budget.dart';

/// Fails when bundled assets exceed docs/PERFORMANCE_BUDGET.md budgets.
void main() {
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
  final problems = checkAssetBudget(assets)..forEach(stdout.writeln);
  final total = assets.fold<int>(0, (sum, asset) => sum + asset.bytes);
  stdout.writeln(
    'check_asset_budget: ${assets.length} assets, $total B, '
    '${problems.length} problems',
  );
  if (problems.isNotEmpty) exitCode = 1;
}
