import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/motion/primitives/perspective_tilt.dart';
import 'package:jdonuts/core/motion/transitions/hero_tags.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';

/// White product card: code, optional New badge, name, price and hero image.
class ProductInfoCard extends StatelessWidget {
  const ProductInfoCard({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.xxlAll,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.xl,
          spacing.xl,
          spacing.xl,
          spacing.xxxl,
        ),
        child: _CardContent(product: product),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  const _CardContent({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CardHeader(product: product),
        SizedBox(height: spacing.sm),
        Text(product.name, style: context.typography.headline),
        SizedBox(height: spacing.xs),
        Text(
          context.l10n.priceMmk(MmkFormatter.amount(product.priceMmk)),
          style: context.typography.title,
        ),
        SizedBox(height: spacing.lg),
        _HeroImage(product: product),
      ],
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          product.code,
          style: context.typography.caption.copyWith(
            color: context.colors.textDisabled,
          ),
        ),
      ),
      if (product.isNew) const _NewBadge(),
    ],
  );
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.highlight,
      borderRadius: context.radius.smAll,
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.sm,
        vertical: context.spacing.xs,
      ),
      child: Text(
        context.l10n.productNewBadge,
        style: context.typography.label.copyWith(
          color: context.colors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox.square(
      dimension: context.layout.heroImageExtent,
      child: PerspectiveTilt(
        child: Hero(
          tag: HeroTags.productImage(product.id),
          child: AppImage(
            image: ImageRef.fromSources(
              asset: product.imageAsset,
              url: product.imageUrl,
            ),
            fit: BoxFit.contain,
            semanticLabel: product.name,
          ),
        ),
      ),
    ),
  );
}
