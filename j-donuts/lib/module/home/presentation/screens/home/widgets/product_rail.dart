import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_section/home_section_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/product_tile.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/section_header.dart';

/// Width fraction for seasonal specials tiles (next card peeks).
const double _seasonalTileWidthFraction = 0.7;

/// Width fraction for popular / order-again tiles (next card peeks).
const double _catalogTileWidthFraction = 0.38;

/// Tile count shown while a rail loads.
const int _skeletonTileCount = 3;

/// Seasonal image height relative to tile width.
const double _seasonalImageHeightFactor = 0.7;

/// Catalog image is near-square.
const double _catalogImageHeightFactor = 1;

/// Title line width relative to the tile.
const double _tileTitleWidthFactor = 0.85;

/// Subtitle line width relative to the tile.
const double _tileSubtitleWidthFactor = 0.55;

/// Price line width relative to the tile.
const double _tilePriceWidthFactor = 0.4;

/// Horizontal product rail backed by its own [HomeSectionBloc].
class ProductRail extends StatelessWidget {
  const ProductRail({
    required this.onProductSelected,
    required this.onSeeAll,
    super.key,
  });

  final ValueChanged<String> onProductSelected;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final kind = context.read<HomeSectionBloc>().kind;
    return BlocBuilder<HomeSectionBloc, ViewState<HomeSection>>(
      builder: (context, state) => ViewStateBuilder<HomeSection>(
        state: state,
        skeleton: _RailSkeleton(kind: kind),
        emptyMessage: context.l10n.sectionEmpty,
        onRetry: () =>
            context.read<HomeSectionBloc>().add(const HomeSectionRetried()),
        builder: (context, section) => _RailContent(
          section: section,
          onProductSelected: onProductSelected,
          onSeeAll: onSeeAll,
        ),
      ),
    );
  }
}

double _tileWidthFraction(HomeSectionKind kind) =>
    kind == HomeSectionKind.seasonal
    ? _seasonalTileWidthFraction
    : _catalogTileWidthFraction;

class _RailContent extends StatelessWidget {
  const _RailContent({
    required this.section,
    required this.onProductSelected,
    required this.onSeeAll,
  });

  final HomeSection section;
  final ValueChanged<String> onProductSelected;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final tileWidth = layout.size.width * _tileWidthFraction(section.kind);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: section.title, onSeeAll: onSeeAll),
        SizedBox(height: context.spacing.lg),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: layout.horizontalGutter),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.spacing.md,
            children: [
              for (final product in section.items)
                ProductTile(
                  product: product,
                  kind: section.kind,
                  width: tileWidth,
                  onTap: () => onProductSelected(product.productId),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Section title, see-all control and kind-specific product tile shapes.
class _RailSkeleton extends StatelessWidget {
  const _RailSkeleton({required this.kind});

  final HomeSectionKind kind;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final spacing = context.spacing;
    final tileWidth = layout.size.width * _tileWidthFraction(kind);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeaderSkeleton(),
        SizedBox(height: spacing.lg),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: layout.horizontalGutter),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing.md,
            children: [
              for (var i = 0; i < _skeletonTileCount; i++)
                _ProductTileSkeleton(kind: kind, width: tileWidth),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeaderSkeleton extends StatelessWidget {
  const _SectionHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.layout.horizontalGutter,
      ),
      child: Row(
        children: [
          Expanded(
            child: SkeletonBlock(
              width: spacing.xxxl * 3,
              height: spacing.lg,
            ),
          ),
          SkeletonBlock(
            width: spacing.xxl,
            height: spacing.xxl,
            borderRadius: context.radius.pillAll,
          ),
        ],
      ),
    );
  }
}

class _ProductTileSkeleton extends StatelessWidget {
  const _ProductTileSkeleton({required this.kind, required this.width});

  final HomeSectionKind kind;
  final double width;

  @override
  Widget build(BuildContext context) {
    final isSeasonal = kind == HomeSectionKind.seasonal;
    final imageHeight = width *
        (isSeasonal ? _seasonalImageHeightFactor : _catalogImageHeightFactor);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBlock(
            width: width,
            height: imageHeight,
            borderRadius: context.radius.xlAll,
          ),
          SizedBox(height: context.spacing.sm),
          _ProductTileTextSkeleton(kind: kind, width: width),
        ],
      ),
    );
  }
}

class _ProductTileTextSkeleton extends StatelessWidget {
  const _ProductTileTextSkeleton({required this.kind, required this.width});

  final HomeSectionKind kind;
  final double width;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isSeasonal = kind == HomeSectionKind.seasonal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(
          width: width * _tileTitleWidthFactor,
          height: spacing.md,
        ),
        SizedBox(height: spacing.xs),
        SkeletonBlock(
          width: width * _tileSubtitleWidthFactor,
          height: spacing.sm,
        ),
        if (!isSeasonal) ...[
          SizedBox(height: spacing.sm),
          SkeletonBlock(
            width: width * _tilePriceWidthFactor,
            height: spacing.md,
          ),
        ],
      ],
    );
  }
}
