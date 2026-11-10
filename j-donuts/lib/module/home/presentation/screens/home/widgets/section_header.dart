import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: context.layout.horizontalGutter),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: context.typography.title),
          ),
        ),
        const _SeeAllButton(),
      ],
    ),
  );
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        boxShadow: context.shadows.card,
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacing.sm),
        child: Icon(
          Icons.chevron_right_rounded,
          size: context.iconSizes.sm,
          color: colors.textPrimary,
          semanticLabel: context.l10n.sectionSeeAll,
        ),
      ),
    );
  }
}
