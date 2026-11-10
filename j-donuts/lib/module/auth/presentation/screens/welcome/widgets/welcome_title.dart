import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      context.l10n.welcomeTitle,
      textAlign: TextAlign.center,
      style: context.typography.headline,
    ),
  );
}
