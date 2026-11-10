part of 'onboarding_bloc.dart';

sealed class OnboardingEvent {
  const OnboardingEvent();
}

enum OnboardingAction { register, login }

final class OnboardingActionSelected extends OnboardingEvent {
  const OnboardingActionSelected(this.action);

  final OnboardingAction action;
}

final class OnboardingReturned extends OnboardingEvent {
  const OnboardingReturned();
}
