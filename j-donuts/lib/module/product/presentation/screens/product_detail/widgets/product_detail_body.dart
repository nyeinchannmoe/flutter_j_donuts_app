import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/fade_slide_in.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';
import 'package:jdonuts/module/product/presentation/screens/product_detail/widgets/product_description_section.dart';
import 'package:jdonuts/module/product/presentation/screens/product_detail/widgets/product_info_card.dart';
import 'package:jdonuts/module/product/presentation/screens/product_detail/widgets/quantity_stepper.dart';

class ProductDetailBody extends StatelessWidget {
  const ProductDetailBody({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final gutter = context.layout.horizontalGutter;
    return ListView(
      padding: EdgeInsets.fromLTRB(gutter, spacing.sm, gutter, spacing.xl),
      children: [
        FadeSlideIn(child: _CardWithQuantity(product: product)),
        SizedBox(height: spacing.xl),
        FadeSlideIn(child: ProductDescriptionSection(product: product)),
        SizedBox(height: spacing.lg),
      ],
    );
  }
}

class _CardWithQuantity extends StatelessWidget {
  const _CardWithQuantity({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final overlap = context.spacing.xxl;
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: overlap),
          child: ProductInfoCard(product: product),
        ),
        const QuantityStepper(),
      ],
    );
  }
}
