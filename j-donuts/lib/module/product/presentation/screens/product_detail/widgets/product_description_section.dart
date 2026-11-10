import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';

/// "What's this?" label rail plus the product description.
class ProductDescriptionSection extends StatelessWidget {
  const ProductDescriptionSection({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _WhatsThisLabel(),
        const _SectionDivider(),
        Expanded(
          child: Text(
            product.description,
            style: context.typography.body.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      child: VerticalDivider(
        width: spacing.xxs,
        thickness: spacing.xxs / 2,
        color: context.colors.border,
      ),
    );
  }
}

class _WhatsThisLabel extends StatelessWidget {
  const _WhatsThisLabel();

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.iconSizes.illustration),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HelpIcon(),
          SizedBox(height: spacing.sm),
          Semantics(
            header: true,
            child: Text(
              context.l10n.productWhatsThis,
              style: context.typography.bodyStrong.copyWith(
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpIcon extends StatelessWidget {
  const _HelpIcon();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.success,
      shape: BoxShape.circle,
    ),
    child: Padding(
      padding: EdgeInsets.all(context.spacing.xs),
      child: Icon(
        Icons.question_mark_rounded,
        size: context.iconSizes.sm,
        color: context.colors.onPrimary,
      ),
    ),
  );
}
