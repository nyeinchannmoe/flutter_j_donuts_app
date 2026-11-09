#!/usr/bin/env bash
# Builds obfuscated release artifacts into dist/ and keeps the matching
# debug symbols in symbols/ (both git-ignored). See docs/RELEASE.md.
#
# Environment:
#   ENVIRONMENT   development | staging | production (default production)
#   API_BASE_URL  enables the remote catalog when set
#   BUILD_NUMBER  overrides the build number from pubspec.yaml
set -euo pipefail

cd "$(dirname "$0")/.."

environment="${ENVIRONMENT:-production}"
defines=(--dart-define="ENVIRONMENT=${environment}")
if [[ -n "${API_BASE_URL:-}" ]]; then
  defines+=(--dart-define=REMOTE_ENABLED=true --dart-define="API_BASE_URL=${API_BASE_URL}")
fi
build_args=(--release --obfuscate "${defines[@]}")
if [[ -n "${BUILD_NUMBER:-}" ]]; then
  build_args+=(--build-number="${BUILD_NUMBER}")
fi

if [[ ! -f android/key.properties ]]; then
  echo 'warning: android/key.properties missing; Android artifacts are debug-signed' >&2
fi

bash tool/verify.sh

mkdir -p dist

flutter build appbundle "${build_args[@]}" --split-debug-info=symbols/android
cp build/app/outputs/bundle/release/app-release.aab dist/

flutter build apk "${build_args[@]}" --split-per-abi --split-debug-info=symbols/android
cp build/app/outputs/flutter-apk/app-*-release.apk dist/

if [[ "$(uname -s)" == "Darwin" ]]; then
  flutter build ipa "${build_args[@]}" --split-debug-info=symbols/ios
  cp build/ios/ipa/*.ipa dist/
else
  echo 'iOS skipped: building an IPA needs macOS with Xcode.' >&2
fi

echo "Artifacts in dist/, symbols in symbols/ (${environment})."
