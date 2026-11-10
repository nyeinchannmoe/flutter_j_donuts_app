import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/motion/transitions/hero_tags.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';

/// Cover-style product image with an optional discount badge.
class ProductTileImage extends StatelessWidget {
  const ProductTileImage({
    required this.product,
    required this.width,
    required this.height,
    required this.radius,
    required this.enableHero,
    super.key,
  });

  final SectionProduct product;
  final double width;
  final double height;
  final BorderRadius radius;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ProductHeroImage(
            product: product,
            radius: radius,
            fit: BoxFit.cover,
            enableHero: enableHero,
          ),
          if (discount != null)
            PositionedDirectional(
              bottom: context.spacing.xs,
              end: context.spacing.xs,
              child: ProductDiscountBadge(percent: discount),
            ),
        ],
      ),
    );
  }
}

/// Contained product image used inside the catalog card chrome.
class ProductHeroImage extends StatelessWidget {
  const ProductHeroImage({
    required this.product,
    required this.radius,
    required this.fit,
    required this.enableHero,
    super.key,
  });

  final SectionProduct product;
  final BorderRadius radius;
  final BoxFit fit;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: radius,
      child: AppImage(
        image: ImageRef.fromSources(
          asset: product.imageAsset,
          url: product.imageUrl,
        ),
        fit: fit,
        semanticLabel: product.name,
      ),
    );
    if (!enableHero) return image;
    return Hero(tag: HeroTags.productImage(product.productId), child: image);
  }
}

/// Discount chip anchored on product imagery.
class ProductDiscountBadge extends StatelessWidget {
  const ProductDiscountBadge({required this.percent, super.key});

  final int percent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.highlight,
      border: Border.all(color: context.colors.onPrimary),
      borderRadius: context.radius.pillAll,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.md,
        vertical: context.spacing.sm,
      ),
      child: Text(
        context.l10n.discountBadge(percent),
        style: context.typography.label.copyWith(
          color: context.colors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
