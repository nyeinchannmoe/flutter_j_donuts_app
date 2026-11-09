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

/// Fraction of the screen width taken by one product tile.
const double _tileWidthFraction = 0.36;

/// Tile count shown while a rail loads.
const int _skeletonTileCount = 3;

/// Horizontal product rail backed by its own [HomeSectionBloc].
class ProductRail extends StatelessWidget {
  const ProductRail({required this.onProductSelected, super.key});

  final ValueChanged<String> onProductSelected;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeSectionBloc, ViewState<HomeSection>>(
        builder: (context, state) => ViewStateBuilder<HomeSection>(
          state: state,
          skeleton: const _RailSkeleton(),
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

class _RailContent extends StatelessWidget {
  const _RailContent({required this.section, required this.onProductSelected});

  final HomeSection section;
  final ValueChanged<String> onProductSelected;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final tileWidth = layout.size.width * _tileWidthFraction;
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
  const _RailSkeleton();

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final tileWidth = layout.size.width * _tileWidthFraction;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.horizontalGutter),
      child: Row(
        spacing: context.spacing.md,
        children: [
          for (var i = 0; i < _skeletonTileCount; i++)
            SkeletonBlock(width: tileWidth, height: tileWidth),
        ],
      ),
    );
  }
}
