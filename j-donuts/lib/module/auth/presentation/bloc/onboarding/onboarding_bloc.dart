import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingPreparing()) {
    on<OnboardingPrepared>((event, emit) {
      if (state is OnboardingPreparing) emit(const OnboardingReady());
    }, transformer: droppable());
    on<OnboardingActionSelected>((event, emit) {
      if (state is OnboardingReady) emit(OnboardingOpening(event.action));
    }, transformer: droppable());
    on<OnboardingPlaceholderRequested>((event, emit) {
      final current = state;
      if (current is! OnboardingReady) return;
      emit(OnboardingReady(noticeEpoch: current.noticeEpoch + 1));
    }, transformer: sequential());
    on<OnboardingReturned>((event, emit) {
      emit(const OnboardingReady());
    }, transformer: sequential());
  }
}
