import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/images/app_image.dart';
import 'package:jdonuts/core/images/image_ref.dart';
import 'package:jdonuts/core/motion/primitives/fade_slide_in.dart';
import 'package:jdonuts/core/motion/primitives/perspective_tilt.dart';
import 'package:jdonuts/core/motion/transitions/hero_tags.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';
import 'package:jdonuts/module/product/presentation/screens/product_detail/widgets/quantity_stepper.dart';

class ProductDetailBody extends StatelessWidget {
  const ProductDetailBody({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: context.layout.horizontalGutter,
      ),
      children: [
        Center(child: _heroImage(context)),
        SizedBox(height: spacing.xl),
        FadeSlideIn(child: _ProductSummary(product: product)),
        SizedBox(height: spacing.xl),
        FadeSlideIn(child: _ProductDescription(product: product)),
        SizedBox(height: spacing.xl),
      ],
    );
  }

  Widget _heroImage(BuildContext context) => SizedBox.square(
    dimension: context.layout.heroImageExtent,
    child: PerspectiveTilt(
      child: Hero(
        tag: HeroTags.productImage(product.id),
        child: ClipOval(
          child: AppImage(
            image: ImageRef.fromSources(
              asset: product.imageAsset,
              url: product.imageUrl,
            ),
            semanticLabel: product.name,
          ),
        ),
      ),
    ),
  );
}

class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.spacing.xs,
      children: [
        if (product.isNew)
          Text(
            context.l10n.productNewBadge.toUpperCase(),
            style: typography.label.copyWith(color: colors.accent),
          ),
        Text(product.name, style: typography.headline),
        Text(
          product.code,
          style: typography.caption.copyWith(color: colors.textSecondary),
        ),
        _priceRow(context),
      ],
    );
  }

  Widget _priceRow(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          context.l10n.priceMmk(MmkFormatter.amount(product.priceMmk)),
          style: context.typography.title.copyWith(
            color: context.colors.primary,
          ),
        ),
      ),
      const QuantityStepper(),
    ],
  );
}

class _ProductDescription extends StatelessWidget {
  const _ProductDescription({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: context.spacing.sm,
    children: [
      Semantics(
        header: true,
        child: Text(
          context.l10n.productWhatsThis,
          style: context.typography.subtitle,
        ),
      ),
      Text(
        product.description,
        style: context.typography.body.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
    ],
  );
}
