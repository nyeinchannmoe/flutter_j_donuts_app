import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/module/auth/presentation/bloc/welcome/welcome_bloc.dart';

void main() {
  group('WelcomeBloc', () {
    test('starts preparing until the hero is ready', () {
      expect(WelcomeBloc().state, isA<WelcomePreparing>());
    });

    blocTest<WelcomeBloc, WelcomeState>(
      'marks the screen ready after prepare',
      build: WelcomeBloc.new,
      act: (bloc) => bloc.add(const WelcomePrepared()),
      expect: () => [const WelcomeReady()],
    );

    blocTest<WelcomeBloc, WelcomeState>(
      'explores once while already exploring',
      build: WelcomeBloc.new,
      seed: () => const WelcomeReady(),
      act: (bloc) {
        bloc
          ..add(const WelcomeExploreSelected())
          ..add(const WelcomeExploreSelected());
      },
      expect: () => [const WelcomeExploring()],
    );

    blocTest<WelcomeBloc, WelcomeState>(
      'ignores explore while preparing',
      build: WelcomeBloc.new,
      act: (bloc) => bloc.add(const WelcomeExploreSelected()),
      expect: () => <WelcomeState>[],
    );
  });
}
