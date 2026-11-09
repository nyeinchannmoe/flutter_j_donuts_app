import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

/// Plain brand background shown while the session status is unknown.
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(gradient: context.colors.authGradient),
    child: Center(
      child: Icon(
        Icons.donut_large_rounded,
        size: context.iconSizes.illustration,
        color: context.colors.accent,
        semanticLabel: context.l10n.appTitle,
      ),
    ),
  );
}
