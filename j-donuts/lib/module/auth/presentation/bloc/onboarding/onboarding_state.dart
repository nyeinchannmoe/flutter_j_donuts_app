part of 'onboarding_bloc.dart';

sealed class OnboardingState {
  const OnboardingState();
}

final class OnboardingReady extends OnboardingState {
  const OnboardingReady();
}

final class OnboardingOpening extends OnboardingState {
  const OnboardingOpening(this.action);

  final OnboardingAction action;
}
