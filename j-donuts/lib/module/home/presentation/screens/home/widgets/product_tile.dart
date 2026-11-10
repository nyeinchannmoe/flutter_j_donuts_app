import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/motion/primitives/pressable_scale.dart';
import 'package:jdonuts/core/motion/transitions/hero_tags.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';

/// Seasonal product image height relative to tile width (near-square).
const double _seasonalImageHeightFactor = 0.95;

/// Catalog titles always reserve this many lines so card heights stay even.
const int _catalogTitleMaxLines = 2;

class ProductTile extends StatelessWidget {
  const ProductTile({
    required this.product,
    required this.kind,
    required this.width,
    required this.onTap,
    super.key,
  });

  final SectionProduct product;
  final HomeSectionKind kind;
  final double width;
  final VoidCallback onTap;

  bool get _isSeasonal => kind == HomeSectionKind.seasonal;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: PressableScale(
      onTap: onTap,
      child: _isSeasonal
          ? _SeasonalBody(product: product, width: width)
          : _CatalogBody(product: product, width: width),
    ),
  );
}

class _SeasonalBody extends StatelessWidget {
  const _SeasonalBody({required this.product, required this.width});

  final SectionProduct product;
  final double width;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _TileImage(
        product: product,
        width: width,
        height: width * _seasonalImageHeightFactor,
        radius: context.radius.xlAll,
      ),
      SizedBox(height: context.spacing.sm),
      _SeasonalLabels(product: product),
    ],
  );
}

class _SeasonalLabels extends StatelessWidget {
  const _SeasonalLabels({required this.product});

  final SectionProduct product;

  @override
  Widget build(BuildContext context) => Text(
    product.name,
    style: context.typography.subtitle.copyWith(
      fontWeight: FontWeight.w700,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

class _CatalogBody extends StatelessWidget {
  const _CatalogBody({required this.product, required this.width});

  final SectionProduct product;
  final double width;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CatalogImageFrame(
        product: product,
        width: width,
        height: width * 1.5,
      ),
      SizedBox(height: context.spacing.sm),
      _ProductName(name: product.name),
    ],
  );
}

/// Fixed white surface that holds only the product image (and discount badge).
class _CatalogImageFrame extends StatelessWidget {
  const _CatalogImageFrame({
    required this.product,
    required this.width,
    required this.height,
  });

  final SectionProduct product;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.lgAll,
        boxShadow: context.shadows.card,
      ),
      child: _CatalogImageStack(product: product),
    ),
  );
}

class _CatalogImageStack extends StatelessWidget {
  const _CatalogImageStack({required this.product});

  final SectionProduct product;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.all(context.spacing.md),
          child: _HeroImage(
            product: product,
            radius: context.radius.mdAll,
            fit: BoxFit.contain,
          ),
        ),
        if (discount != null)
          PositionedDirectional(
            bottom: context.spacing.xs,
            end: context.spacing.xs,
            child: _DiscountBadge(percent: discount),
          ),
      ],
    );
  }
}

class _ProductName extends StatelessWidget {
  const _ProductName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final style = context.typography.bodyStrong;
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(style.fontSize!) * style.height!;
    return SizedBox(
      height: lineHeight * _catalogTitleMaxLines,
      width: double.infinity,
      child: Text(
        name,
        style: style,
        maxLines: _catalogTitleMaxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TileImage extends StatelessWidget {
  const _TileImage({
    required this.product,
    required this.width,
    required this.height,
    required this.radius,
  });

  final SectionProduct product;
  final double width;
  final double height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _HeroImage(
            product: product,
            radius: radius,
            fit: BoxFit.cover,
          ),
          if (discount != null)
            PositionedDirectional(
              bottom: context.spacing.xs,
              end: context.spacing.xs,
              child: _DiscountBadge(percent: discount),
            ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({
    required this.product,
    required this.radius,
    required this.fit,
  });

  final SectionProduct product;
  final BorderRadius radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Hero(
    tag: HeroTags.productImage(product.productId),
    child: ClipRRect(
      borderRadius: radius,
      child: AppImage(
        image: ImageRef.fromSources(
          asset: product.imageAsset,
          url: product.imageUrl,
        ),
        fit: fit,
        semanticLabel: product.name,
      ),
    ),
  );
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.highlight,
      borderRadius: context.radius.pillAll,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm,
        vertical: context.spacing.xs,
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
