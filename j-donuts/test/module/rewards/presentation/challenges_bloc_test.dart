import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/module/rewards/domain/entities/challenge.dart';
import 'package:jdonuts/module/rewards/domain/usecases/watch_challenges.dart';
import 'package:jdonuts/module/rewards/presentation/bloc/challenges/challenges_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchChallenges extends Mock implements WatchChallenges {}

const Challenge _challenge = Challenge(
  id: 'c_donuts',
  title: 'Buy 4 donuts',
  kind: ChallengeKind.donut,
  progressCurrent: 2,
  progressTarget: 4,
  rewardPoints: 200,
  imageAsset: 'assets/seed/images/c_donuts.webp',
  claimed: false,
);

typedef _State = ViewState<List<Challenge>>;

void main() {
  late _MockWatchChallenges watch;

  setUp(() => watch = _MockWatchChallenges());

  ChallengesBloc build() => ChallengesBloc(watchChallenges: watch);

  void stubResults(List<Result<List<Challenge>>> results) =>
      when(watch.call).thenAnswer((_) => Stream.fromIterable(results));

  group('ChallengesBloc', () {
    blocTest<ChallengesBloc, _State>(
      'emits the challenges',
      setUp: () => stubResults([
        const Ok([_challenge]),
      ]),
      build: build,
      act: (bloc) => bloc.add(const ChallengesStarted()),
      expect: () => const [
        _State.loading(),
        _State.data([_challenge]),
      ],
    );

    blocTest<ChallengesBloc, _State>(
      'emits empty when there are no challenges',
      setUp: () => stubResults([const Ok([])]),
      build: build,
      act: (bloc) => bloc.add(const ChallengesStarted()),
      expect: () => const [_State.loading(), _State.empty()],
    );

    blocTest<ChallengesBloc, _State>(
      'emits failure and recovers on retry',
      setUp: () {
        var calls = 0;
        when(watch.call).thenAnswer(
          (_) => Stream.value(
            calls++ == 0 ? const Err(StorageFailure()) : const Ok([_challenge]),
          ),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const ChallengesStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ChallengesRetried());
      },
      expect: () => const [
        _State.loading(),
        _State.failure(StorageFailure()),
        _State.loading(),
        _State.data([_challenge]),
      ],
    );
  });
}
