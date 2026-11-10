import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/module/auth/presentation/bloc/onboarding/onboarding_bloc.dart';

void main() {
  group('OnboardingBloc', () {
    test('starts preparing until the hero is ready', () {
      expect(OnboardingBloc().state, isA<OnboardingPreparing>());
    });

    blocTest<OnboardingBloc, OnboardingState>(
      'marks the screen ready after prepare',
      build: OnboardingBloc.new,
      act: (bloc) => bloc.add(const OnboardingPrepared()),
      expect: () => [const OnboardingReady()],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'opens registration once while already opening',
      build: OnboardingBloc.new,
      seed: () => const OnboardingReady(),
      act: (bloc) {
        bloc
          ..add(const OnboardingActionSelected(OnboardingAction.register))
          ..add(const OnboardingActionSelected(OnboardingAction.login));
      },
      expect: () => [
        const OnboardingOpening(OnboardingAction.register),
      ],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'returns to ready after navigation finishes',
      build: OnboardingBloc.new,
      seed: () => const OnboardingOpening(OnboardingAction.login),
      act: (bloc) => bloc.add(const OnboardingReturned()),
      expect: () => [const OnboardingReady()],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'bumps the notice epoch for coming-soon placeholders',
      build: OnboardingBloc.new,
      seed: () => const OnboardingReady(),
      act: (bloc) => bloc.add(const OnboardingPlaceholderRequested()),
      expect: () => [const OnboardingReady(noticeEpoch: 1)],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'ignores actions while preparing',
      build: OnboardingBloc.new,
      act: (bloc) =>
          bloc.add(const OnboardingActionSelected(OnboardingAction.register)),
      expect: () => <OnboardingState>[],
    );
  });
}
