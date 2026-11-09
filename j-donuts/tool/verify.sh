#!/usr/bin/env bash
# Runs every check from the definition of done, in order, and stops at the
# first failure. Set VERIFY_INTEGRATION=1 to also run the integration test
# on the connected device or emulator.
set -euo pipefail

cd "$(dirname "$0")/.."

step() { printf '\n==> %s\n' "$1"; }

hand_written_dart_files() {
  find lib test tool integration_test -name '*.dart' \
    ! -name '*.g.dart' \
    ! -name '*.freezed.dart' \
    ! -path 'lib/l10n/generated/*' \
    ! -path 'test/core/database/generated/*' \
    ! -path 'lib/core/database/migrations/schema_versions.dart' \
    -print0
}

step 'Dependencies'
flutter pub get

step 'Code generation'
dart run build_runner build

step 'Localization'
flutter gen-l10n

step 'Formatting'
hand_written_dart_files | xargs -0 dart format --output=none --set-exit-if-changed

step 'Analyzer'
flutter analyze

step 'Unit and widget tests'
flutter test

step 'Quality gate'
dart run tool/quality_gate.dart

step 'Asset budget'
dart run tool/check_asset_budget.dart

if [[ "${VERIFY_INTEGRATION:-0}" == "1" ]]; then
  step 'Integration test'
  flutter test integration_test
fi

step 'All checks passed'
