import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/pressable_scale.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/domain/entities/shop.dart';
import 'package:jdonuts/module/home/presentation/bloc/shops/shops_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/shop_card.dart';

/// Explore Now landscape illustration behind the nearby shops band.
const String _shopsBackgroundAsset = 'assets/images/home/home_background.png';

/// Card width as a fraction of screen width so the next card peeks.
const double _shopCardWidthFraction = 0.72;

/// Approximate band height while shops are loading.
const double _skeletonHeightFactor = 0.55;

class NearbyShops extends StatelessWidget {
  const NearbyShops({
    required this.onExploreNow,
    required this.onOrderOnline,
    super.key,
  });

  final VoidCallback onExploreNow;
  final ValueChanged<String> onOrderOnline;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ShopsBloc, ViewState<List<Shop>>>(
        builder: (context, state) => ViewStateBuilder<List<Shop>>(
          state: state,
          skeleton: SkeletonBlock(
            height: context.layout.size.height * _skeletonHeightFactor,
            borderRadius: BorderRadius.zero,
          ),
          emptyMessage: context.l10n.shopsEmpty,
          onRetry: () => context.read<ShopsBloc>().add(const ShopsRetried()),
          builder: (context, shops) => _ShopsContent(
            shops: shops,
            onExploreNow: onExploreNow,
            onOrderOnline: onOrderOnline,
          ),
        ),
      );
}

class _ShopsContent extends StatelessWidget {
  const _ShopsContent({
    required this.shops,
    required this.onExploreNow,
    required this.onOrderOnline,
  });

  final List<Shop> shops;
  final VoidCallback onExploreNow;
  final ValueChanged<String> onOrderOnline;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final gutter = context.layout.horizontalGutter;
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_shopsBackgroundAsset),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              child: _ShopsHeader(
                shopCount: shops.length,
                onExploreNow: onExploreNow,
              ),
            ),
            SizedBox(height: spacing.xl),
            _ShopsCarousel(shops: shops, onOrderOnline: onOrderOnline),
          ],
        ),
      ),
    );
  }
}

class _ShopsHeader extends StatelessWidget {
  const _ShopsHeader({
    required this.shopCount,
    required this.onExploreNow,
  });

  final int shopCount;
  final VoidCallback onExploreNow;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            context.l10n.shopsTitle(shopCount),
            style: context.typography.headline.copyWith(
              color: colors.onPrimary,
            ),
          ),
        ),
        SizedBox(height: spacing.lg),
        _ExploreNowButton(onPressed: onExploreNow),
      ],
    );
  }
}

class _ExploreNowButton extends StatelessWidget {
  const _ExploreNowButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    return PressableScale(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: context.radius.pillAll,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.xl,
            vertical: spacing.sm,
          ),
          child: Text(
            context.l10n.shopsExploreNow.toUpperCase(),
            style: context.typography.button.copyWith(color: colors.primary),
          ),
        ),
      ),
    );
  }
}

class _ShopsCarousel extends StatelessWidget {
  const _ShopsCarousel({
    required this.shops,
    required this.onOrderOnline,
  });

  final List<Shop> shops;
  final ValueChanged<String> onOrderOnline;

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final spacing = context.spacing;
    final cardWidth = layout.size.width * _shopCardWidthFraction;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(
        layout.horizontalGutter,
        spacing.xs,
        layout.horizontalGutter,
        spacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.md,
        children: [
          for (final shop in shops)
            ShopCard(
              shop: shop,
              width: cardWidth,
              onOrderOnline: () => onOrderOnline(shop.id),
            ),
        ],
      ),
    );
  }
}
