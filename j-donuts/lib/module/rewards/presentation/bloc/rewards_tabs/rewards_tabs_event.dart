part of 'rewards_tabs_bloc.dart';

sealed class RewardsTabsEvent {
  const RewardsTabsEvent();
}

final class RewardsTabSelected extends RewardsTabsEvent {
  const RewardsTabSelected(this.index);

  final int index;
}
