import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/view_state/view_state.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/welcome_screen.dart';
import 'package:jdonuts/module/product/domain/entities/product.dart';
import 'package:jdonuts/module/product/presentation/bloc/product_detail/product_detail_bloc.dart';
import 'package:jdonuts/module/product/presentation/screens/product_detail/product_detail_screen.dart';
import 'package:jdonuts/module/product/presentation/screens/product_detail/widgets/add_to_cart_bar.dart';

import '../helpers/device_matrix.dart';
import '../helpers/pump_app.dart';

class _MockProductDetailBloc
    extends MockBloc<ProductDetailEvent, ProductDetailState>
    implements ProductDetailBloc {}

const Product _product = Product(
  id: 'p_coconut',
  code: 'JD-001',
  name: 'Strawberry Chocolate Sprinkle Donut',
  priceMmk: 125000,
  isNew: true,
  imageAsset: 'assets/seed/images/p_coconut.webp',
  description:
      'A soft yeast ring dipped in strawberry glaze, finished with dark '
      'chocolate drizzle and rainbow sprinkles. Best enjoyed the same day.',
);

void main() {
  testWidgets(
    'product detail fits every device and text scale',
    variant: DeviceMatrix.variant,
    (tester) async {
      final bloc = _MockProductDetailBloc();
      whenListen(
        bloc,
        const Stream<ProductDetailState>.empty(),
        initialState: const ProductDetailState(
          product: ViewState.data(_product),
          quantity: 12,
        ),
      );

      await tester.pumpOnDevice(
        const ProductDetailScreen(productId: 'p_coconut'),
        providers: [BlocProvider<ProductDetailBloc>.value(value: bloc)],
      );
      await tester.pumpAndSettle();

      expect(find.byType(AddToCartBar), findsOneWidget);
      await tester.scrollUntilVisible(find.text(_product.description), 100);
      expect(find.text(_product.description), findsOneWidget);
    },
  );

  testWidgets(
    'onboarding fits every device and text scale',
    variant: DeviceMatrix.variant,
    (tester) async {
      await tester.pumpOnDevice(
        OnboardingScreen(onGetStarted: () {}, onLogIn: () {}),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    },
  );

  testWidgets(
    'welcome fits every device and text scale',
    variant: DeviceMatrix.variant,
    (tester) async {
      await tester.pumpOnDevice(WelcomeScreen(onExplore: () {}));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
    },
  );
}
