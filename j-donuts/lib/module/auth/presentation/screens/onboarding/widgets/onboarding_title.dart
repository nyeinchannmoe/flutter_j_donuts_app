import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

class OnboardingTitle extends StatelessWidget {
  const OnboardingTitle({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      context.l10n.onboardingTitle,
      textAlign: TextAlign.center,
      style: context.typography.headline,
    ),
  );
}
