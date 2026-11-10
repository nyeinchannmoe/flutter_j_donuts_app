import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/product_tile.dart';

/// Vertical list of seasonal-style product tiles.
class SectionProductList extends StatelessWidget {
  const SectionProductList({
    required this.products,
    required this.kind,
    required this.onProductSelected,
    super.key,
  });

  final List<SectionProduct> products;
  final HomeSectionKind kind;
  final ValueChanged<String> onProductSelected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final gutter = context.layout.horizontalGutter;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth - gutter * 2;
        return ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: gutter,
            vertical: spacing.lg,
          ),
          itemCount: products.length,
          separatorBuilder: (_, _) => SizedBox(height: spacing.xl),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductTile(
              product: product,
              kind: kind,
              width: tileWidth,
              enableHero: false,
              onTap: () => onProductSelected(product.productId),
            );
          },
        );
      },
    );
  }
}
