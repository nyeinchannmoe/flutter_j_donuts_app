import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/domain/usecases/watch_home_section.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_section/home_section_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchHomeSection extends Mock implements WatchHomeSection {}

const SectionProduct _product = SectionProduct(
  productId: 'p_coconut',
  name: 'Coconut',
  priceMmk: 2500,
  imageAsset: 'assets/seed/images/p_coconut.webp',
);

const HomeSection _section = HomeSection(
  id: 's_popular',
  kind: HomeSectionKind.popular,
  title: 'Popular',
  items: [_product],
);

void main() {
  late _MockWatchHomeSection watch;

  setUp(() => watch = _MockWatchHomeSection());

  HomeSectionBloc build() =>
      HomeSectionBloc(watchHomeSection: watch, kind: HomeSectionKind.popular);

  void stubResults(List<Result<HomeSection?>> results) => when(
    () => watch(HomeSectionKind.popular),
  ).thenAnswer((_) => Stream.fromIterable(results));

  group('HomeSectionBloc', () {
    test('starts loading', () {
      expect(build().state, const ViewState<HomeSection>.loading());
    });

    blocTest<HomeSectionBloc, ViewState<HomeSection>>(
      'emits data for a section with items',
      setUp: () => stubResults([const Ok(_section)]),
      build: build,
      act: (bloc) => bloc.add(const HomeSectionStarted()),
      expect: () => const [
        ViewState<HomeSection>.loading(),
        ViewState<HomeSection>.data(_section),
      ],
    );

    blocTest<HomeSectionBloc, ViewState<HomeSection>>(
      'emits empty when the section is missing or has no items',
      setUp: () => stubResults([
        const Ok(null),
        Ok(_section.copyWith(items: const [])),
      ]),
      build: build,
      act: (bloc) => bloc.add(const HomeSectionStarted()),
      expect: () => const [
        ViewState<HomeSection>.loading(),
        ViewState<HomeSection>.empty(),
      ],
    );

    blocTest<HomeSectionBloc, ViewState<HomeSection>>(
      'emits failure when the repository reports one',
      setUp: () => stubResults([const Err(StorageFailure())]),
      build: build,
      act: (bloc) => bloc.add(const HomeSectionStarted()),
      expect: () => const [
        ViewState<HomeSection>.loading(),
        ViewState<HomeSection>.failure(StorageFailure()),
      ],
    );

    blocTest<HomeSectionBloc, ViewState<HomeSection>>(
      'follows later database changes',
      setUp: () => stubResults([const Ok(null), const Ok(_section)]),
      build: build,
      act: (bloc) => bloc.add(const HomeSectionStarted()),
      expect: () => const [
        ViewState<HomeSection>.loading(),
        ViewState<HomeSection>.empty(),
        ViewState<HomeSection>.data(_section),
      ],
    );

    blocTest<HomeSectionBloc, ViewState<HomeSection>>(
      'retry replaces a failed subscription with a fresh one',
      setUp: () {
        var calls = 0;
        when(() => watch(HomeSectionKind.popular)).thenAnswer(
          (_) => Stream.value(
            calls++ == 0 ? const Err(StorageFailure()) : const Ok(_section),
          ),
        );
      },
      build: build,
      act: (bloc) async {
        bloc.add(const HomeSectionStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const HomeSectionRetried());
      },
      expect: () => const [
        ViewState<HomeSection>.loading(),
        ViewState<HomeSection>.failure(StorageFailure()),
        ViewState<HomeSection>.loading(),
        ViewState<HomeSection>.data(_section),
      ],
      verify: (_) => verify(() => watch(HomeSectionKind.popular)).called(2),
    );
  });
}
