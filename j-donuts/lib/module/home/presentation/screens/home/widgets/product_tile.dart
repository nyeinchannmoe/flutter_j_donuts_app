import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/motion/primitives/pressable_scale.dart';
import 'package:jdonuts/core/motion/transitions/hero_tags.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    required this.product,
    required this.width,
    required this.onTap,
    super.key,
  });

  final SectionProduct product;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: PressableScale(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TileImage(product: product, extent: width),
          SizedBox(height: context.spacing.sm),
          Text(
            product.name,
            style: context.typography.bodyStrong,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            context.l10n.priceMmk(MmkFormatter.amount(product.priceMmk)),
            style: context.typography.caption.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _TileImage extends StatelessWidget {
  const _TileImage({required this.product, required this.extent});

  final SectionProduct product;
  final double extent;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;
    return SizedBox.square(
      dimension: extent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: HeroTags.productImage(product.productId),
            child: ClipRRect(
              borderRadius: context.radius.lgAll,
              child: AppImage(
                image: ImageRef.fromSources(
                  asset: product.imageAsset,
                  url: product.imageUrl,
                ),
                semanticLabel: product.name,
              ),
            ),
          ),
          if (discount != null)
            PositionedDirectional(
              top: context.spacing.sm,
              start: context.spacing.sm,
              child: _DiscountBadge(percent: discount),
            ),
        ],
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.accent,
      borderRadius: context.radius.pillAll,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm,
        vertical: context.spacing.xxs,
      ),
      child: Text(
        context.l10n.discountBadge(percent),
        style: context.typography.label.copyWith(
          color: context.colors.onPrimary,
        ),
      ),
    ),
  );
}
