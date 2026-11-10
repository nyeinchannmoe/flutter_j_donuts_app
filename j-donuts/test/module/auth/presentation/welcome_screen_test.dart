import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/presentation/bloc/welcome/welcome_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/welcome_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/widgets/welcome_hero.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/widgets/welcome_hero_painter.dart';

import '../../../helpers/device_matrix.dart';
import '../../../helpers/pump_app.dart';

final AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));

Future<void> _pumpScreen(
  WidgetTester tester, {
  MotionTier tier = MotionTier.full,
  Future<void>? exploreGate,
  double textScale = 1,
  Size size = DeviceMatrix.phone,
  bool forceHeroFallback = false,
  void Function(int count)? onExplore,
}) async {
  var explores = 0;
  await tester.pumpApp(
    Builder(
      builder: (context) => WelcomeScreen(
        debugForceHeroFallback: forceHeroFallback,
        onExplore: () async {
          explores += 1;
          onExplore?.call(explores);
          if (exploreGate != null) await exploreGate;
          if (context.mounted) {
            await Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Home stub')),
                ),
              ),
            );
          }
        },
      ),
    ),
    providers: [
      BlocProvider<WelcomeBloc>(
        create: (_) => WelcomeBloc()..add(const WelcomePrepared()),
      ),
    ],
    tier: tier,
    textScale: textScale,
    size: size,
  );
}

void main() {
  testWidgets('renders the title, button and hero', (tester) async {
    await _pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeHero), findsOneWidget);
    expect(find.text(_l10n.welcomeTitle), findsOneWidget);
    expect(find.text(_l10n.welcomeExplore), findsOneWidget);
  });

  testWidgets('double tap opens home once', (tester) async {
    final gate = Completer<void>();
    var explores = 0;
    await _pumpScreen(
      tester,
      exploreGate: gate.future,
      onExplore: (count) => explores = count,
    );
    await tester.pumpAndSettle();
    final button = find.text(_l10n.welcomeExplore);
    await tester.tap(button);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();
    gate.complete();
    await tester.pumpAndSettle();

    expect(explores, 1);
    expect(find.text('Home stub'), findsOneWidget);
  });

  for (final size in [DeviceMatrix.smallPhone, DeviceMatrix.largePhone]) {
    testWidgets('fits ${size.width} dp at 1.3x without overflow', (
      tester,
    ) async {
      await _pumpScreen(tester, textScale: 1.3, size: size);
      await tester.pumpAndSettle();
      expect(find.text(_l10n.welcomeTitle), findsOneWidget);
      final explore = find.text(_l10n.welcomeExplore);
      await tester.ensureVisible(explore);
      await tester.pumpAndSettle();
      expect(explore.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reduced motion shows the controls on the first frame', (
    tester,
  ) async {
    await _pumpScreen(tester, tier: MotionTier.minimal);
    expect(
      find.descendant(
        of: find.byType(StaggeredItem),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    expect(find.text(_l10n.welcomeTitle).hitTestable(), findsOneWidget);
    expect(find.text(_l10n.welcomeExplore).hitTestable(), findsOneWidget);
  });

  testWidgets('hero fallback paints when the image is forced off', (
    tester,
  ) async {
    await _pumpScreen(tester, forceHeroFallback: true);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is WelcomeHeroPainter,
      ),
      findsOneWidget,
    );
  });
}
