import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/fade_slide_in.dart';
import 'package:jdonuts/core/motion/primitives/pop_in.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({required this.onExplore, super.key});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(gradient: context.colors.authGradient),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.layout.horizontalGutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _content(context),
          ),
        ),
      ),
    ),
  );

  List<Widget> _content(BuildContext context) => [
    Expanded(
      child: Center(
        child: PopIn(
          child: Icon(
            Icons.celebration_rounded,
            size: context.iconSizes.illustration,
            color: context.colors.accent,
          ),
        ),
      ),
    ),
    FadeSlideIn(
      child: Text(
        context.l10n.welcomeTitle,
        textAlign: TextAlign.center,
        style: context.typography.display,
      ),
    ),
    SizedBox(height: context.spacing.xxl),
    AppButton(label: context.l10n.welcomeExplore, onPressed: onExplore),
  ];
}
