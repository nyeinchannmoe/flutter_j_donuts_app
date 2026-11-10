part of 'onboarding_bloc.dart';

@immutable
sealed class OnboardingState {
  const OnboardingState();
}

@immutable
final class OnboardingPreparing extends OnboardingState {
  const OnboardingPreparing();

  @override
  bool operator ==(Object other) => other is OnboardingPreparing;

  @override
  int get hashCode => runtimeType.hashCode;
}

@immutable
final class OnboardingReady extends OnboardingState {
  const OnboardingReady({this.noticeEpoch = 0});

  final int noticeEpoch;

  @override
  bool operator ==(Object other) =>
      other is OnboardingReady && other.noticeEpoch == noticeEpoch;

  @override
  int get hashCode => noticeEpoch.hashCode;
}

@immutable
final class OnboardingOpening extends OnboardingState {
  const OnboardingOpening(this.action);

  final OnboardingAction action;

  @override
  bool operator ==(Object other) =>
      other is OnboardingOpening && other.action == action;

  @override
  int get hashCode => action.hashCode;
}
