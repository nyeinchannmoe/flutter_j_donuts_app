part of 'challenges_bloc.dart';

sealed class ChallengesEvent {
  const ChallengesEvent();
}

final class ChallengesStarted extends ChallengesEvent {
  const ChallengesStarted();
}

final class ChallengesRetried extends ChallengesEvent {
  const ChallengesRetried();
}
