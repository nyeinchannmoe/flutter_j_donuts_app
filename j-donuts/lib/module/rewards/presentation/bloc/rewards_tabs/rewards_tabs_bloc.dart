import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';

part 'rewards_tabs_event.dart';
part 'rewards_tabs_state.dart';

class RewardsTabsBloc extends Bloc<RewardsTabsEvent, RewardsTabsState> {
  RewardsTabsBloc({int initialIndex = 0})
    : super(RewardsTabsState(selectedIndex: initialIndex)) {
    on<RewardsTabSelected>((event, emit) {
      if (event.index == state.selectedIndex) return;
      emit(RewardsTabsState(selectedIndex: event.index));
    }, transformer: sequential());
  }
}
