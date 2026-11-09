import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/state_views/empty_state_view.dart';

/// Tab content for destinations that are outside the demo scope.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.background,
    appBar: AppBar(
      backgroundColor: context.colors.background,
      title: Text(title, style: context.typography.title),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.placeholderTitle,
            style: context.typography.subtitle,
          ),
          EmptyStateView(
            message: context.l10n.placeholderMessage,
            icon: Icons.hourglass_empty_rounded,
          ),
        ],
      ),
    ),
  );
}
