import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';

/// Shop cards shown while nearby shops load.
const int _shopSkeletonCardCount = 2;

/// Card width fraction so the next card peeks (matches the live shops rail).
const double _shopCardWidthFraction = 0.72;

/// Shop image width-to-height ratio (matches the live shop card).
const double _shopImageAspectRatio = 1.45;

/// Title line width relative to the shop card.
const double _shopTitleWidthFactor = 0.7;

/// Address line width relative to the shop card.
const double _shopAddressWidthFactor = 0.9;

/// Order-online action width relative to the shop card.
const double _shopActionWidthFactor = 0.35;

/// Title, explore CTA and shop-card shaped placeholders.
class NearbyShopsSkeleton extends StatelessWidget {
  const NearbyShopsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final gutter = context.layout.horizontalGutter;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: const _ShopsHeaderSkeleton(),
          ),
          SizedBox(height: spacing.xl),
          const _ShopsCarouselSkeleton(),
        ],
      ),
    );
  }
}

class _ShopsHeaderSkeleton extends StatelessWidget {
  const _ShopsHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(width: spacing.xxxl * 4, height: spacing.xl),
        SizedBox(height: spacing.lg),
        SkeletonBlock(
          width: spacing.xxxl * 2,
          height: spacing.xl,
          borderRadius: context.radius.pillAll,
        ),
      ],
    );
  }
}

class _ShopsCarouselSkeleton extends StatelessWidget {
  const _ShopsCarouselSkeleton();

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final spacing = context.spacing;
    final cardWidth = layout.size.width * _shopCardWidthFraction;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: layout.horizontalGutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: spacing.md,
        children: [
          for (var i = 0; i < _shopSkeletonCardCount; i++)
            _ShopCardSkeleton(width: cardWidth),
        ],
      ),
    );
  }
}

class _ShopCardSkeleton extends StatelessWidget {
  const _ShopCardSkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: context.radius.xlAll,
        ),
        child: Padding(
          padding: EdgeInsets.all(spacing.md),
          child: _ShopCardSkeletonBody(width: width),
        ),
      ),
    );
  }
}

class _ShopCardSkeletonBody extends StatelessWidget {
  const _ShopCardSkeletonBody({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBlock(
          width: width - spacing.md * 2,
          height: width / _shopImageAspectRatio,
          borderRadius: context.radius.lgAll,
        ),
        SizedBox(height: spacing.md),
        SkeletonBlock(
          width: width * _shopTitleWidthFactor,
          height: spacing.md,
        ),
        SizedBox(height: spacing.xs),
        SkeletonBlock(
          width: width * _shopAddressWidthFactor,
          height: spacing.sm,
        ),
        SizedBox(height: spacing.sm),
        SkeletonBlock(
          width: width * _shopActionWidthFactor,
          height: spacing.md,
        ),
      ],
    );
  }
}
