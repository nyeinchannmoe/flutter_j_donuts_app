import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/theme/app_theme.dart';

/// Plain brand background shown while the session status is unknown.
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) => AnnotatedRegion(
    value: AppTheme.lightSystemBars,
    child: DecoratedBox(
      decoration: BoxDecoration(gradient: context.colors.authGradient),
      child: const SizedBox.expand(),
    ),
  );
}
