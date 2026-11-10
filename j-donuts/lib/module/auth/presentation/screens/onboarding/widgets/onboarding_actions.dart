import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_press_feedback.dart';

class OnboardingActions extends StatefulWidget {
  const OnboardingActions({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  State<OnboardingActions> createState() => _OnboardingActionsState();
}

class _OnboardingActionsState extends State<OnboardingActions> {
  final _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OnboardingPressFeedback(
    states: _states,
    child: FilledButton(
      statesController: _states,
      onPressed: widget.onPressed,
      child: Text(
        context.l10n.onboardingGetStarted,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
