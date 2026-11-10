# Performance budget

## Asset budget

Enforced by `dart run tool/check_asset_budget.dart` (rules in
`tool/src/asset_budget.dart`, tests in `test/tool/asset_budget_test.dart`).
The check fails CI when any limit is exceeded.

| Asset | Limit |
| --- | --- |
| One seed image in `assets/seed/images/` | 20 KiB, WebP only |
| All seed images together | 300 KiB |
| `assets/seed/catalog.json` | 64 KiB |
| One font file in `assets/fonts/` | 160 KiB |
| Everything under `assets/` | 1 MiB |

Seed images are generated placeholders (`tool/generate_seed_images.py`).
Real photos can replace them under the same filenames as long as they stay
inside these limits. Network images go through `AppImage` and the shared
`AppImageCacheManager`, never through bundled assets.

## Frame budget

`FrameBudgetMonitor` defaults, mirrored in `ANIMATION_GUIDE.md`:

| Setting | Value |
| --- | --- |
| Frame budget | 20 ms build plus raster |
| Window | 120 frames |
| Jank threshold | more than 25 % of frames in a window over budget |
| Downgrade | after 2 consecutive janky windows, full to reduced, once per session |

In profile builds each closed window logs its over-budget percentage.
`attach` is a no-op in debug builds so non-representative timings cannot
downgrade the motion tier during development.

## Rendering rules

- Animate transform and opacity only. No animated blur, `BackdropFilter`,
  animated shadows or `Opacity` over large subtrees.
- One `AnimationController` per orchestrated screen section, never one per
  list item. Inactive tabs mute their tickers.
- At most two ambient animations visible at once.
- Painters sit in a `RepaintBoundary`, take `repaint:` and allocate nothing
  in `paint`.
- Lists are lazy (`ListView.builder`, slivers). `AppImage` decodes images at their
  display width (`cacheWidth`, `memCacheWidth`).

## Startup

The first frame waits only for the local seed check, the session and the
locale. Network sync, connectivity probing and frame monitoring start after
that without being awaited.

## Release size

Release builds use `--obfuscate`, `--split-debug-info` and split per-ABI
APKs (`tool/build_release.sh`). Keep debug symbols from `symbols/` for crash
symbolication.
