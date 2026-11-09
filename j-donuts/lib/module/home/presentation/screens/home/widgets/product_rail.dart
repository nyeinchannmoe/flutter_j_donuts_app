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
const double _seasonalTileWidthFraction = 0.58;

/// Width fraction for popular / order-again tiles.
const double _catalogTileWidthFraction = 0.36;

/// Tile count shown while a rail loads.
const int _skeletonTileCount = 3;

/// Matches catalog tile image height factor used by [ProductTile].
const double _catalogSkeletonHeightFactor = 1.15;

/// Matches seasonal tile image height factor used by [ProductTile].
const double _seasonalSkeletonHeightFactor = 0.95;

/// Horizontal product rail backed by its own [HomeSectionBloc].
class ProductRail extends StatelessWidget {
  const ProductRail({required this.onProductSelected, super.key});

  final ValueChanged<String> onProductSelected;

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
  const _RailContent({required this.section, required this.onProductSelected});

  final HomeSection section;
  final ValueChanged<String> onProductSelected;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final tileWidth = layout.size.width * _tileWidthFraction(section.kind);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: section.title),
        SizedBox(height: context.spacing.md),
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

class _RailSkeleton extends StatelessWidget {
  const _RailSkeleton({required this.kind});

  final HomeSectionKind kind;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final tileWidth = layout.size.width * _tileWidthFraction(kind);
    final tileHeight = kind == HomeSectionKind.seasonal
        ? tileWidth * _seasonalSkeletonHeightFactor
        : tileWidth * _catalogSkeletonHeightFactor;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.horizontalGutter),
      child: Row(
        spacing: context.spacing.md,
        children: [
          for (var i = 0; i < _skeletonTileCount; i++)
            SkeletonBlock(width: tileWidth, height: tileHeight),
        ],
      ),
    );
  }
}
