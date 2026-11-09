# Release

## Signing

Android release signing reads `android/key.properties`, which is
git-ignored and must never be committed:

```properties
storeFile=/absolute/path/to/upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

Without this file, release builds fall back to the debug key. That is fine
for local smoke tests, but those builds cannot be uploaded to Play.

iOS signing uses the team configured in Xcode on a macOS machine.

## Build

```sh
ENVIRONMENT=production API_BASE_URL=https://api.example.com BUILD_NUMBER=42 \
  bash tool/build_release.sh
```

| Variable | Default | Effect |
| --- | --- | --- |
| `ENVIRONMENT` | `production` | `development`, `staging` or `production` |
| `API_BASE_URL` | empty | When set, also defines `REMOTE_ENABLED=true` so the app syncs from the API |
| `BUILD_NUMBER` | from `pubspec.yaml` | Overrides the build number |

The script runs `tool/verify.sh` first, then builds:

- an Android App Bundle and split per-ABI APKs, both with `--obfuscate`;
- an IPA, only when running on macOS.

Artifacts go to `dist/` and debug symbols to `symbols/`. Both are
git-ignored. Archive `symbols/` with each release, because obfuscated
stack traces cannot be read without it:

```sh
flutter symbolize -i stacktrace.txt -d symbols/android/app.android-arm64.symbols
```

## Troubleshooting

- The first Android build installs NDK 28.2.13676358 through Gradle. It
  needs network access to `dl.google.com`.
- The `sqlite3` build hook downloads a prebuilt `libsqlite3.so` per ABI from
  the sqlite3.dart GitHub release and checks its SHA-256. A proxy or gateway
  error shows up as "Hash of downloaded file ... is ..., expected ...". Delete
  the `download-*` folder that contains a `.tmp` file under
  `.dart_tool/hooks_runner/shared/sqlite3/build` and rebuild.
- If one ABI keeps failing, `--target-platform android-arm,android-arm64`
  builds the ABIs that real phones use.

## Versioning

Bump `version:` in `pubspec.yaml` (`major.minor.patch+build`) for every
store release, or pass `BUILD_NUMBER` to the build script.

## CI

`.github/workflows/ci.yml` runs on every pull request and every push to
`main`. The verify job runs `tool/verify.sh`. When it passes, a second job
builds an obfuscated, debug-signed release APK and uploads it together with
its symbols as a 14-day workflow artifact. Store uploads are manual.

## Checklist

1. `bash tool/verify.sh` passes locally.
2. Run the integration test on an emulator or device:
   `flutter test integration_test`.
3. Bump the version and build with `tool/build_release.sh`.
4. Install the APK on a real device and walk through sign-in, home, product
   detail and rewards, online and offline.
5. Archive `dist/` and `symbols/`.
