import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/rewards_tabs/rewards_tabs_bloc.dart';

void main() {
  group('RewardsTabsBloc', () {
    test('starts on the earn tab', () {
      expect(RewardsTabsBloc().state.selectedIndex, 0);
    });

    blocTest<RewardsTabsBloc, RewardsTabsState>(
      'selects a different tab',
      build: RewardsTabsBloc.new,
      act: (bloc) => bloc.add(const RewardsTabSelected(1)),
      expect: () => [const RewardsTabsState(selectedIndex: 1)],
    );

    blocTest<RewardsTabsBloc, RewardsTabsState>(
      'ignores selecting the current tab',
      build: RewardsTabsBloc.new,
      act: (bloc) => bloc.add(const RewardsTabSelected(0)),
      expect: () => <RewardsTabsState>[],
    );

    blocTest<RewardsTabsBloc, RewardsTabsState>(
      'ignores a duplicate selection while opening another tab',
      build: RewardsTabsBloc.new,
      act: (bloc) {
        bloc
          ..add(const RewardsTabSelected(1))
          ..add(const RewardsTabSelected(1));
      },
      expect: () => [const RewardsTabsState(selectedIndex: 1)],
    );
  });
}
