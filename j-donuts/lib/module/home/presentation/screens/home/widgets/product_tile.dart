import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/pressable_scale.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/product_tile_media.dart';

/// Seasonal product image height relative to tile width (near-square).
const double _seasonalImageHeightFactor = 0.7;

/// Catalog titles always reserve this many lines so card heights stay even.
const int _catalogTitleMaxLines = 2;

class ProductTile extends StatelessWidget {
  const ProductTile({
    required this.product,
    required this.kind,
    required this.width,
    required this.onTap,
    this.enableHero = true,
    super.key,
  });

  final SectionProduct product;
  final HomeSectionKind kind;
  final double width;
  final VoidCallback onTap;

  /// Disable when the same product Hero may already be mounted (e.g. Home).
  final bool enableHero;

  bool get _isSeasonal => kind == HomeSectionKind.seasonal;
  bool get _isPopular => kind == HomeSectionKind.popular;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: PressableScale(
      onTap: onTap,
      child: _isSeasonal
          ? _SeasonalBody(
              product: product,
              width: width,
              enableHero: enableHero,
            )
          : _CatalogBody(
              product: product,
              isPopular: _isPopular,
              width: width,
              enableHero: enableHero,
            ),
    ),
  );
}

class _SeasonalBody extends StatelessWidget {
  const _SeasonalBody({
    required this.product,
    required this.width,
    required this.enableHero,
  });

  final SectionProduct product;
  final double width;
  final bool enableHero;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ProductTileImage(
        product: product,
        width: width,
        height: width * _seasonalImageHeightFactor,
        radius: context.radius.xlAll,
        enableHero: enableHero,
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
  const _CatalogBody({
    required this.product,
    required this.isPopular,
    required this.width,
    required this.enableHero,
  });

  final SectionProduct product;
  final bool isPopular;
  final double width;
  final bool enableHero;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CatalogImageFrame(
        product: product,
        width: width,
        height: width * (isPopular ? 1.5 : 1),
        enableHero: enableHero,
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
    required this.enableHero,
  });

  final SectionProduct product;
  final double width;
  final double height;
  final bool enableHero;

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
      child: _CatalogImageStack(product: product, enableHero: enableHero),
    ),
  );
}

class _CatalogImageStack extends StatelessWidget {
  const _CatalogImageStack({required this.product, required this.enableHero});

  final SectionProduct product;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.all(context.spacing.md),
          child: ProductHeroImage(
            product: product,
            radius: context.radius.mdAll,
            fit: BoxFit.contain,
            enableHero: enableHero,
          ),
        ),
        if (discount != null)
          PositionedDirectional(
            bottom: context.spacing.xs,
            end: context.spacing.xs,
            child: ProductDiscountBadge(percent: discount),
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
