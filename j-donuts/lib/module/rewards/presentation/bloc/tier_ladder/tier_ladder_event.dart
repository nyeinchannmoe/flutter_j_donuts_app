part of 'tier_ladder_bloc.dart';

sealed class TierLadderEvent {
  const TierLadderEvent();
}

final class TierLadderStarted extends TierLadderEvent {
  const TierLadderStarted();
}

final class TierLadderRetried extends TierLadderEvent {
  const TierLadderRetried();
}
