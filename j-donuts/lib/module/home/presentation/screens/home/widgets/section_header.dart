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
        Icon(
          Icons.arrow_forward,
          size: context.iconSizes.md,
          color: context.colors.textPrimary,
          semanticLabel: context.l10n.sectionSeeAll,
        ),
      ],
    ),
  );
}
