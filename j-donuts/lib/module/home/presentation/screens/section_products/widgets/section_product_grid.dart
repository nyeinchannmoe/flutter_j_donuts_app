import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/theme/tokens/app_spacing.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/product_tile.dart';

/// Columns for the catalog see-all grid.
const int _gridCrossAxisCount = 2;

/// Catalog titles always reserve this many lines so card heights stay even.
const int _catalogTitleMaxLines = 2;

/// Popular image height relative to tile width.
const double _popularImageHeightFactor = 1.5;

/// Order-again image height relative to tile width.
const double _orderAgainImageHeightFactor = 1;

/// Grid of catalog-style product tiles for popular and order-again.
class SectionProductGrid extends StatelessWidget {
  const SectionProductGrid({
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
      builder: (context, constraints) => _GridBody(
        products: products,
        kind: kind,
        onProductSelected: onProductSelected,
        tileWidth: _tileWidth(constraints.maxWidth, gutter, spacing.md),
        gutter: gutter,
        spacing: spacing,
      ),
    );
  }
}

double _tileWidth(double maxWidth, double gutter, double gap) {
  final gapsWidth = gap * (_gridCrossAxisCount - 1);
  return (maxWidth - gutter * 2 - gapsWidth) / _gridCrossAxisCount;
}

class _GridBody extends StatelessWidget {
  const _GridBody({
    required this.products,
    required this.kind,
    required this.onProductSelected,
    required this.tileWidth,
    required this.gutter,
    required this.spacing,
  });

  final List<SectionProduct> products;
  final HomeSectionKind kind;
  final ValueChanged<String> onProductSelected;
  final double tileWidth;
  final double gutter;
  final AppSpacing spacing;

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: EdgeInsets.symmetric(horizontal: gutter, vertical: spacing.lg),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: _gridCrossAxisCount,
      crossAxisSpacing: spacing.md,
      mainAxisSpacing: spacing.lg,
      mainAxisExtent: _tileExtent(context, tileWidth, kind),
    ),
    itemCount: products.length,
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
}

double _tileExtent(
  BuildContext context,
  double tileWidth,
  HomeSectionKind kind,
) {
  final imageFactor = kind == HomeSectionKind.popular
      ? _popularImageHeightFactor
      : _orderAgainImageHeightFactor;
  final style = context.typography.bodyStrong;
  final lineHeight =
      MediaQuery.textScalerOf(context).scale(style.fontSize!) * style.height!;
  return tileWidth * imageFactor +
      context.spacing.sm +
      lineHeight * _catalogTitleMaxLines;
}
