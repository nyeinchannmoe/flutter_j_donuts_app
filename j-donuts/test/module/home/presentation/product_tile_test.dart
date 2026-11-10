import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/module/home/domain/entities/home_section.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/product_tile.dart';

import '../../../helpers/pump_app.dart';

const SectionProduct _discounted = SectionProduct(
  productId: 'p_mistletoe_box',
  name: 'Mistletoe Romance box',
  priceMmk: 18000,
  imageAsset: 'assets/seed/images/card_mistletoe_clean.jpg',
  discountPercent: 50,
);

const SectionProduct _plain = SectionProduct(
  productId: 'p_strawberry_chocolate',
  name: 'Strawberry Chocolate Donuts',
  priceMmk: 3500,
  imageAsset: 'assets/seed/images/p_strawberry_chocolate.webp',
);

void main() {
  testWidgets('shows a bottom-end discount badge from product data', (
    tester,
  ) async {
    await tester.pumpApp(
      Scaffold(
        body: ProductTile(
          product: _discounted,
          kind: HomeSectionKind.seasonal,
          width: 160,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('50% off'), findsOneWidget);
    expect(find.textContaining('MMK'), findsNothing);
    expect(find.textContaining('18,000'), findsNothing);
  });

  testWidgets('hides the badge when discountPercent is null', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: ProductTile(
          product: _plain,
          kind: HomeSectionKind.popular,
          width: 140,
          onTap: () {},
        ),
      ),
    );

    expect(find.textContaining('% off'), findsNothing);
    expect(find.text('Strawberry Chocolate Donuts'), findsOneWidget);
  });

  testWidgets('seasonal tiles omit the catalog card chrome', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: ProductTile(
          product: _plain,
          kind: HomeSectionKind.seasonal,
          width: 200,
          onTap: () {},
        ),
      ),
    );

    final material = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
    final hasCardShadow = material.any((box) {
      final decoration = box.decoration;
      return decoration is BoxDecoration && decoration.boxShadow != null;
    });
    expect(hasCardShadow, isFalse);
  });

  testWidgets('popular tiles use elevated surface card chrome', (tester) async {
    await tester.pumpApp(
      Scaffold(
        body: ProductTile(
          product: _plain,
          kind: HomeSectionKind.popular,
          width: 140,
          onTap: () {},
        ),
      ),
    );

    final material = tester.widgetList<DecoratedBox>(find.byType(DecoratedBox));
    final hasCardShadow = material.any((box) {
      final decoration = box.decoration;
      return decoration is BoxDecoration &&
          decoration.boxShadow != null &&
          decoration.boxShadow!.isNotEmpty;
    });
    expect(hasCardShadow, isTrue);
  });

  testWidgets(
    'catalog image frames stay equal height for one and two line titles',
    (tester) async {
      const short = SectionProduct(
        productId: 'p_short',
        name: 'Coffee',
        priceMmk: 3500,
        imageAsset: 'assets/seed/images/p_strawberry_chocolate.webp',
      );
      const long = SectionProduct(
        productId: 'p_long',
        name: 'Strawberry Chocolate Donuts',
        priceMmk: 3500,
        imageAsset: 'assets/seed/images/p_strawberry_chocolate.webp',
      );
      const tileWidth = 140.0;

      await tester.pumpApp(
        Scaffold(
          body: Row(
            children: [
              ProductTile(
                product: short,
                kind: HomeSectionKind.orderAgain,
                width: tileWidth,
                onTap: () {},
              ),
              ProductTile(
                product: long,
                kind: HomeSectionKind.orderAgain,
                width: tileWidth,
                onTap: () {},
              ),
            ],
          ),
        ),
      );

      Size frameSizeFor(String productId) {
        final tile = find.byWidgetPredicate(
          (widget) =>
              widget is ProductTile && widget.product.productId == productId,
        );
        return tester.getSize(
          find.descendant(of: tile, matching: find.byType(DecoratedBox)).first,
        );
      }

      final shortFrame = frameSizeFor('p_short');
      final longFrame = frameSizeFor('p_long');

      expect(shortFrame, equals(const Size(tileWidth, tileWidth)));
      expect(longFrame, equals(shortFrame));
    },
  );

  testWidgets('invokes onTap when pressed', (tester) async {
    var taps = 0;
    await tester.pumpApp(
      Scaffold(
        body: ProductTile(
          product: _plain,
          kind: HomeSectionKind.orderAgain,
          width: 140,
          onTap: () => taps += 1,
        ),
      ),
    );

    await tester.tap(find.text('Strawberry Chocolate Donuts'));
    await tester.pump();
    expect(taps, 1);
  });
}
