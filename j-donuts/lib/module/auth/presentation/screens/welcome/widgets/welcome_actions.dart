import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/buttons/pressable_scale.dart';

class WelcomeActions extends StatelessWidget {
  const WelcomeActions({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => PressableScale(
    onTap: onPressed,
    child: FilledButton(
      onPressed: onPressed,
      child: Text(
        context.l10n.welcomeExplore,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
