import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/domain/entities/home_banner.dart';
import 'package:jdonuts/module/home/domain/usecases/watch_banners.dart';
import 'package:jdonuts/module/home/presentation/bloc/banners/banners_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/banner_carousel.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockWatchBanners extends Mock implements WatchBanners {}

const HomeBanner _central = HomeBanner(
  id: 'b_central_boulevard',
  tag: 'New shop',
  title: 'We are now at Central Boulevard',
  imageAsset: 'assets/seed/images/b_central_boulevard.webp',
);

const HomeBanner _hot = HomeBanner(
  id: 'b_hot_drinks',
  tag: 'Hot',
  title: 'Hot drinks are back for the cold season',
  imageAsset: 'assets/seed/images/b_hot_drinks.webp',
);

void main() {
  late _MockWatchBanners watch;

  setUp(() => watch = _MockWatchBanners());

  testWidgets('renders banner tag and title from data', (tester) async {
    when(
      () => watch(),
    ).thenAnswer((_) => Stream.value(const Ok([_central, _hot])));

    await tester.pumpApp(
      BlocProvider(
        create: (_) =>
            BannersBloc(watchBanners: watch)..add(const BannersStarted()),
        child: const Scaffold(body: BannerCarousel()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('New shop'), findsOneWidget);
    expect(find.text('We are now at Central Boulevard'), findsOneWidget);
  });

  testWidgets('shows skeleton while banners are loading', (tester) async {
    final controller = StreamController<Result<List<HomeBanner>>>();
    addTearDown(controller.close);
    when(() => watch()).thenAnswer((_) => controller.stream);

    await tester.pumpApp(
      BlocProvider(
        create: (_) =>
            BannersBloc(watchBanners: watch)..add(const BannersStarted()),
        child: const Scaffold(body: BannerCarousel()),
      ),
    );
    await tester.pump();

    expect(find.byType(SkeletonBlock), findsWidgets);
  });

  testWidgets('shows the empty message when there are no banners', (
    tester,
  ) async {
    when(() => watch()).thenAnswer((_) => Stream.value(const Ok([])));

    await tester.pumpApp(
      BlocProvider(
        create: (_) =>
            BannersBloc(watchBanners: watch)..add(const BannersStarted()),
        child: const Scaffold(body: BannerCarousel()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('No promotions right now.'), findsOneWidget);
  });
}
