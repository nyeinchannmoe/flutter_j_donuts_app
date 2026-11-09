import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/motion/primitives/pressable_scale.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/core/view_state/view_state_builder.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/domain/entities/shop.dart';
import 'package:jdonuts/module/home/presentation/bloc/shops/shops_bloc.dart';

/// Width of the shop photo relative to illustration token.
const double _shopPhotoWidthFactor = 1.4;

class NearbyShops extends StatelessWidget {
  const NearbyShops({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ShopsBloc, ViewState<List<Shop>>>(
        builder: (context, state) => ViewStateBuilder<List<Shop>>(
          state: state,
          skeleton: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.layout.horizontalGutter,
            ),
            child: SkeletonBlock(height: context.iconSizes.illustration),
          ),
          emptyMessage: context.l10n.shopsEmpty,
          onRetry: () => context.read<ShopsBloc>().add(const ShopsRetried()),
          builder: (context, shops) => _ShopsBand(shops: shops),
        ),
      );
}

class _ShopsBand extends StatelessWidget {
  const _ShopsBand({required this.shops});

  final List<Shop> shops;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final gutter = context.layout.horizontalGutter;
    return DecoratedBox(
      decoration: BoxDecoration(color: context.colors.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(gutter, spacing.xl, gutter, spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: spacing.lg,
          children: [
            _ShopsHeadline(count: shops.length),
            const _ExploreNowButton(),
            for (final shop in shops) _ShopCard(shop: shop),
          ],
        ),
      ),
    );
  }
}

class _ShopsHeadline extends StatelessWidget {
  const _ShopsHeadline({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      context.l10n.shopsTitle(count),
      style: context.typography.title.copyWith(
        color: context.colors.onPrimary,
      ),
    ),
  );
}

class _ExploreNowButton extends StatelessWidget {
  const _ExploreNowButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: () {},
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: context.radius.pillAll,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.xl,
            vertical: context.spacing.md,
          ),
          child: Text(
            context.l10n.shopsExploreNow.toUpperCase(),
            textAlign: TextAlign.center,
            style: context.typography.button.copyWith(color: colors.primary),
          ),
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final photoWidth = context.iconSizes.illustration * _shopPhotoWidthFactor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.lgAll,
        boxShadow: context.shadows.card,
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShopPhoto(shop: shop, width: photoWidth),
            SizedBox(width: spacing.md),
            Expanded(child: _ShopDetails(shop: shop)),
          ],
        ),
      ),
    );
  }
}

class _ShopPhoto extends StatelessWidget {
  const _ShopPhoto({required this.shop, required this.width});

  final Shop shop;
  final double width;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: context.radius.mdAll,
    child: SizedBox(
      width: width,
      height: context.iconSizes.illustration,
      child: AppImage(
        image: ImageRef.fromSources(
          asset: shop.imageAsset,
          url: shop.imageUrl,
        ),
        semanticLabel: shop.name,
      ),
    ),
  );
}

class _ShopDetails extends StatelessWidget {
  const _ShopDetails({required this.shop});

  final Shop shop;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        shop.name,
        style: context.typography.bodyStrong,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: context.spacing.xxs),
      Text(
        shop.address,
        style: context.typography.caption.copyWith(
          color: context.colors.textSecondary,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: context.spacing.sm),
      const _OrderOnlineLink(),
    ],
  );
}

class _OrderOnlineLink extends StatelessWidget {
  const _OrderOnlineLink();

  @override
  Widget build(BuildContext context) => PressableScale(
    onTap: () {},
    child: Text(
      context.l10n.shopsOrderOnline,
      style: context.typography.bodyStrong.copyWith(
        color: context.colors.accent,
      ),
    ),
  );
}
