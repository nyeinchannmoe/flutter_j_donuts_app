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
            child: Text(
              title,
              style: context.typography.title.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const _SeeAllChevron(),
      ],
    ),
  );
}

class _SeeAllChevron extends StatelessWidget {
  const _SeeAllChevron();

  @override
  Widget build(BuildContext context) {
    final extent = context.iconSizes.lg;
    return Semantics(
      label: context.l10n.sectionSeeAll,
      button: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          shape: BoxShape.circle,
          boxShadow: context.shadows.card,
          border: Border.all(color: context.colors.border),
        ),
        child: SizedBox.square(
          dimension: extent,
          child: Icon(
            Icons.chevron_right_rounded,
            size: context.iconSizes.md,
            color: context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
