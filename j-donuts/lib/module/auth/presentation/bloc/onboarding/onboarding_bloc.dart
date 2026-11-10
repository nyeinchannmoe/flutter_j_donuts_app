import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingReady()) {
    on<OnboardingActionSelected>((event, emit) {
      if (state is OnboardingReady) emit(OnboardingOpening(event.action));
    }, transformer: droppable());
    on<OnboardingReturned>((event, emit) {
      emit(const OnboardingReady());
    }, transformer: sequential());
  }
}
