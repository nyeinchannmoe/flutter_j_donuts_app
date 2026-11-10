import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/pressable_scale.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.onSeeAll,
    super.key,
  });

  final String title;
  final VoidCallback onSeeAll;

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
        _SeeAllButton(onPressed: onSeeAll),
      ],
    ),
  );
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PressableScale(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          boxShadow: context.shadows.card,
        ),
        child: Padding(
          padding: EdgeInsets.all(context.spacing.sm),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: context.iconSizes.sm,
            color: colors.textPrimary,
            semanticLabel: context.l10n.sectionSeeAll,
          ),
        ),
      ),
    );
  }
}
