part of 'rewards_tabs_bloc.dart';

@immutable
final class RewardsTabsState {
  const RewardsTabsState({this.selectedIndex = 0});

  final int selectedIndex;

  @override
  bool operator ==(Object other) =>
      other is RewardsTabsState && other.selectedIndex == selectedIndex;

  @override
  int get hashCode => selectedIndex.hashCode;
}
