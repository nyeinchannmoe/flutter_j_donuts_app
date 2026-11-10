import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';

part 'welcome_event.dart';
part 'welcome_state.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc() : super(const WelcomePreparing()) {
    on<WelcomePrepared>((event, emit) {
      if (state is WelcomePreparing) emit(const WelcomeReady());
    }, transformer: droppable());
    on<WelcomeExploreSelected>((event, emit) {
      if (state is WelcomeReady) emit(const WelcomeExploring());
    }, transformer: droppable());
  }
}
