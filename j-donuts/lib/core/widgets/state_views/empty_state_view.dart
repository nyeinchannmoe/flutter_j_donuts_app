import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

/// Compact empty state for a section or screen.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({required this.message, this.icon, super.key});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.all(context.spacing.lg),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon ?? Icons.inbox_outlined,
          size: context.iconSizes.lg,
          color: context.colors.textDisabled,
        ),
        SizedBox(height: context.spacing.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.typography.body.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    ),
  );
}
