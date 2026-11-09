part of 'rewards_summary_bloc.dart';

sealed class RewardsSummaryEvent {
  const RewardsSummaryEvent();
}

final class RewardsSummaryStarted extends RewardsSummaryEvent {
  const RewardsSummaryStarted();
}

final class RewardsSummaryRetried extends RewardsSummaryEvent {
  const RewardsSummaryRetried();
}
