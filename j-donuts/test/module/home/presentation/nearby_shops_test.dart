import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/domain/entities/shop.dart';
import 'package:jdonuts/module/home/domain/usecases/watch_shops.dart';
import 'package:jdonuts/module/home/presentation/bloc/shops/shops_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/nearby_shops.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/nearby_shops_skeleton.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/shop_card.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockWatchShops extends Mock implements WatchShops {}

const Shop _downtown = Shop(
  id: 's_downtown',
  name: "J'Donuts Downtown",
  address: 'Sule Pagoda Road, Kyauktada',
  imageAsset: 'assets/seed/images/card_bakery.jpg',
);

const Shop _junction = Shop(
  id: 's_junction',
  name: "J'Donuts Junction City",
  address: 'Bogyoke Aung San Road, Pabedan',
  imageAsset: 'assets/seed/images/card_cafe.jpg',
);

void main() {
  late _MockWatchShops watch;
  late int exploreTaps;
  late List<String> orderTaps;

  setUp(() {
    watch = _MockWatchShops();
    exploreTaps = 0;
    orderTaps = <String>[];
  });

  Widget subject() => BlocProvider(
    create: (_) => ShopsBloc(watchShops: watch)..add(const ShopsStarted()),
    child: Scaffold(
      body: NearbyShops(
        onExploreNow: () => exploreTaps++,
        onOrderOnline: orderTaps.add,
      ),
    ),
  );

  testWidgets('renders shop count title, CTAs and shop fields', (tester) async {
    when(
      () => watch(),
    ).thenAnswer((_) => Stream.value(const Ok([_downtown, _junction])));

    await tester.pumpApp(subject());
    await tester.pump();
    await tester.pump();

    expect(
      find.text("There are 2 J'Donut shops near you.😋"),
      findsOneWidget,
    );
    expect(find.text('EXPLORE NOW'), findsOneWidget);
    expect(find.text('Order online'), findsNWidgets(2));
    expect(find.text("J'Donuts Downtown"), findsOneWidget);
    expect(find.text('Sule Pagoda Road, Kyauktada'), findsOneWidget);
    expect(find.byType(ShopCard), findsNWidgets(2));

    await tester.tap(find.text('EXPLORE NOW'));
    await tester.pump();
    expect(exploreTaps, 1);

    await tester.tap(find.text('Order online').first);
    await tester.pump();
    expect(orderTaps, ['s_downtown']);
  });

  testWidgets('shows skeleton while shops are loading', (tester) async {
    final controller = StreamController<Result<List<Shop>>>();
    addTearDown(controller.close);
    when(() => watch()).thenAnswer((_) => controller.stream);

    await tester.pumpApp(subject());
    await tester.pump();

    expect(find.byType(NearbyShopsSkeleton), findsOneWidget);
    expect(find.byType(SkeletonBlock), findsWidgets);
  });

  testWidgets('shows empty message when there are no shops', (tester) async {
    when(() => watch()).thenAnswer((_) => Stream.value(const Ok([])));

    await tester.pumpApp(subject());
    await tester.pump();
    await tester.pump();

    expect(find.text('No shops nearby yet.'), findsOneWidget);
    expect(find.text('EXPLORE NOW'), findsNothing);
  });
}
