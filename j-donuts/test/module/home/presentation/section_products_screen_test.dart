import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_block.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/domain/usecases/watch_home_section.dart';
import 'package:jdonuts/module/home/presentation/bloc/home_section/home_section_bloc.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/product_tile.dart';
import 'package:jdonuts/module/home/presentation/screens/section_products/section_products_screen.dart';
import 'package:jdonuts/module/home/presentation/screens/section_products/widgets/section_product_grid.dart';
import 'package:jdonuts/module/home/presentation/screens/section_products/widgets/section_product_list.dart';
import 'package:jdonuts/module/home/presentation/screens/section_products/widgets/section_products_skeleton.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/device_matrix.dart';
import '../../../helpers/pump_app.dart';

class _MockWatchHomeSection extends Mock implements WatchHomeSection {}

const SectionProduct _mistletoe = SectionProduct(
  productId: 'p_mistletoe_box',
  name: 'Mistletoe Romance box',
  priceMmk: 18000,
  imageAsset: 'assets/seed/images/card_mistletoe_clean.jpg',
  discountPercent: 50,
);

const SectionProduct _christmas = SectionProduct(
  productId: 'p_christmas_family_box',
  name: 'Christmas Family box',
  priceMmk: 26000,
  imageAsset: 'assets/seed/images/card_new_christmas.jpg',
);

const SectionProduct _strawberry = SectionProduct(
  productId: 'p_strawberry_chocolate',
  name: 'Strawberry Chocolate Donuts',
  priceMmk: 3500,
  imageAsset: 'assets/seed/images/p_strawberry_chocolate.webp',
);

const SectionProduct _coconut = SectionProduct(
  productId: 'p_coconut',
  name: 'Coconut Donut',
  priceMmk: 3200,
  imageAsset: 'assets/seed/images/p_coconut.webp',
);

void main() {
  late _MockWatchHomeSection watch;
  late List<String> selectedIds;

  setUp(() {
    watch = _MockWatchHomeSection();
    selectedIds = <String>[];
  });

  Widget subject(HomeSectionKind kind) => BlocProvider(
    create: (_) => HomeSectionBloc(watchHomeSection: watch, kind: kind)
      ..add(const HomeSectionStarted()),
    child: SectionProductsScreen(
      kind: kind,
      onProductSelected: selectedIds.add,
    ),
  );

  testWidgets('seasonal section uses a vertical product list', (tester) async {
    when(() => watch(HomeSectionKind.seasonal)).thenAnswer(
      (_) => Stream.value(
        const Ok(
          HomeSection(
            id: 'sec_seasonal',
            kind: HomeSectionKind.seasonal,
            title: 'Seasonal Specials',
            items: [_mistletoe, _christmas],
          ),
        ),
      ),
    );

    await tester.pumpApp(subject(HomeSectionKind.seasonal));
    await tester.pump();
    await tester.pump();

    expect(find.text('Seasonal Specials'), findsOneWidget);
    expect(find.byType(SectionProductList), findsOneWidget);
    expect(find.byType(SectionProductGrid), findsNothing);
    expect(find.byType(ProductTile), findsNWidgets(2));

    await tester.tap(find.text('Mistletoe Romance box'));
    await tester.pump();
    expect(selectedIds, ['p_mistletoe_box']);
  });

  testWidgets('popular section uses a product grid', (tester) async {
    when(() => watch(HomeSectionKind.popular)).thenAnswer(
      (_) => Stream.value(
        const Ok(
          HomeSection(
            id: 'sec_popular',
            kind: HomeSectionKind.popular,
            title: 'Popular',
            items: [_strawberry, _coconut],
          ),
        ),
      ),
    );

    await tester.pumpApp(subject(HomeSectionKind.popular));
    await tester.pump();
    await tester.pump();

    expect(find.text('Popular'), findsOneWidget);
    expect(find.byType(SectionProductGrid), findsOneWidget);
    expect(find.byType(SectionProductList), findsNothing);
    expect(find.byType(ProductTile), findsNWidgets(2));
  });

  testWidgets('orderAgain section uses a product grid', (tester) async {
    when(() => watch(HomeSectionKind.orderAgain)).thenAnswer(
      (_) => Stream.value(
        const Ok(
          HomeSection(
            id: 'sec_order_again',
            kind: HomeSectionKind.orderAgain,
            title: 'Order again',
            items: [_coconut, _strawberry],
          ),
        ),
      ),
    );

    await tester.pumpApp(subject(HomeSectionKind.orderAgain));
    await tester.pump();
    await tester.pump();

    expect(find.byType(SectionProductGrid), findsOneWidget);
    expect(find.byType(ProductTile), findsNWidgets(2));
  });

  testWidgets('shows skeleton while the section loads', (tester) async {
    final controller = StreamController<Result<HomeSection?>>();
    addTearDown(controller.close);
    when(
      () => watch(HomeSectionKind.popular),
    ).thenAnswer((_) => controller.stream);

    await tester.pumpApp(subject(HomeSectionKind.popular));
    await tester.pump();

    expect(find.byType(SectionProductsSkeleton), findsOneWidget);
    expect(find.byType(SkeletonBlock), findsWidgets);
  });

  testWidgets('shows empty message when the section has no products', (
    tester,
  ) async {
    when(() => watch(HomeSectionKind.seasonal)).thenAnswer(
      (_) => Stream.value(const Ok(null)),
    );

    await tester.pumpApp(subject(HomeSectionKind.seasonal));
    await tester.pump();
    await tester.pump();

    expect(find.text('No products in this section yet.'), findsOneWidget);
  });

  testWidgets(
    'survives the device matrix at text scale 1.3',
    (tester) async {
      when(() => watch(HomeSectionKind.popular)).thenAnswer(
        (_) => Stream.value(
          const Ok(
            HomeSection(
              id: 'sec_popular',
              kind: HomeSectionKind.popular,
              title: 'Popular',
              items: [_strawberry, _coconut, _mistletoe, _christmas],
            ),
          ),
        ),
      );

      await tester.pumpOnDevice(subject(HomeSectionKind.popular));
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(ProductTile), findsNWidgets(4));
    },
    variant: DeviceMatrix.variant,
  );
}
