import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/theme/tokens/app_spacing.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';

/// Placeholder tile count while the section catalog loads.
const int _skeletonItemCount = 4;

/// Columns for the catalog see-all skeleton grid.
const int _gridCrossAxisCount = 2;

/// Seasonal image height relative to tile width.
const double _seasonalImageHeightFactor = 0.7;

/// Popular image height relative to tile width.
const double _popularImageHeightFactor = 1.5;

/// Order-again image height relative to tile width.
const double _orderAgainImageHeightFactor = 1;

/// Title line width relative to the tile.
const double _tileTitleWidthFactor = 0.85;

/// Subtitle line width relative to the tile.
const double _tileSubtitleWidthFactor = 0.55;

/// Loading placeholder matching list or grid layout for [kind].
class SectionProductsSkeleton extends StatelessWidget {
  const SectionProductsSkeleton({required this.kind, super.key});

  final HomeSectionKind kind;

  @override
  Widget build(BuildContext context) {
    if (kind == HomeSectionKind.seasonal) {
      return const _ListSkeleton();
    }
    return _GridSkeleton(kind: kind);
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final gutter = context.layout.horizontalGutter;
    return LayoutBuilder(
      builder: (context, constraints) => _ListSkeletonBody(
        tileWidth: constraints.maxWidth - gutter * 2,
        gutter: gutter,
        spacing: spacing,
      ),
    );
  }
}

class _ListSkeletonBody extends StatelessWidget {
  const _ListSkeletonBody({
    required this.tileWidth,
    required this.gutter,
    required this.spacing,
  });

  final double tileWidth;
  final double gutter;
  final AppSpacing spacing;

  @override
  Widget build(BuildContext context) => ListView.separated(
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.symmetric(horizontal: gutter, vertical: spacing.lg),
    itemCount: _skeletonItemCount,
    separatorBuilder: (_, _) => SizedBox(height: spacing.xl),
    itemBuilder: (_, _) => _SeasonalTileSkeleton(width: tileWidth),
  );
}

class _GridSkeleton extends StatelessWidget {
  const _GridSkeleton({required this.kind});

  final HomeSectionKind kind;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final gutter = context.layout.horizontalGutter;
    return LayoutBuilder(
      builder: (context, constraints) => _GridSkeletonBody(
        kind: kind,
        tileWidth: _gridTileWidth(constraints.maxWidth, gutter, spacing.md),
        gutter: gutter,
        spacing: spacing,
      ),
    );
  }
}

double _gridTileWidth(double maxWidth, double gutter, double gap) {
  final gapsWidth = gap * (_gridCrossAxisCount - 1);
  return (maxWidth - gutter * 2 - gapsWidth) / _gridCrossAxisCount;
}

class _GridSkeletonBody extends StatelessWidget {
  const _GridSkeletonBody({
    required this.kind,
    required this.tileWidth,
    required this.gutter,
    required this.spacing,
  });

  final HomeSectionKind kind;
  final double tileWidth;
  final double gutter;
  final AppSpacing spacing;

  @override
  Widget build(BuildContext context) {
    final imageFactor = kind == HomeSectionKind.popular
        ? _popularImageHeightFactor
        : _orderAgainImageHeightFactor;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: gutter, vertical: spacing.lg),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridCrossAxisCount,
        crossAxisSpacing: spacing.md,
        mainAxisSpacing: spacing.lg,
        mainAxisExtent: tileWidth * imageFactor + spacing.sm + spacing.md * 2,
      ),
      itemCount: _skeletonItemCount,
      itemBuilder: (_, _) => _CatalogTileSkeleton(
        width: tileWidth,
        imageHeightFactor: imageFactor,
      ),
    );
  }
}

class _SeasonalTileSkeleton extends StatelessWidget {
  const _SeasonalTileSkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(
          width: width,
          height: width * _seasonalImageHeightFactor,
          borderRadius: context.radius.xlAll,
        ),
        SizedBox(height: spacing.sm),
        SkeletonBlock(
          width: width * _tileTitleWidthFactor,
          height: spacing.md,
        ),
        SizedBox(height: spacing.xs),
        SkeletonBlock(
          width: width * _tileSubtitleWidthFactor,
          height: spacing.sm,
        ),
      ],
    );
  }
}

class _CatalogTileSkeleton extends StatelessWidget {
  const _CatalogTileSkeleton({
    required this.width,
    required this.imageHeightFactor,
  });

  final double width;
  final double imageHeightFactor;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(
          width: width,
          height: width * imageHeightFactor,
          borderRadius: context.radius.lgAll,
        ),
        SizedBox(height: spacing.sm),
        SkeletonBlock(
          width: width * _tileTitleWidthFactor,
          height: spacing.md,
        ),
        SizedBox(height: spacing.xs),
        SkeletonBlock(
          width: width * _tileSubtitleWidthFactor,
          height: spacing.sm,
        ),
      ],
    );
  }
}
