import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/core/theme/tokens/app_colors.dart';
import 'package:jdonuts/core/widgets/legal_footer.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_hero.dart';

import '../../../helpers/device_matrix.dart';
import '../../../helpers/pump_app.dart';

final AppLocalizations _l10n = lookupAppLocalizations(const Locale('en'));

Future<void> _pumpScreen(
  WidgetTester tester, {
  MotionTier tier = MotionTier.full,
  Future<void>? registrationGate,
  double textScale = 1,
  Size size = DeviceMatrix.phone,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpApp(
    Builder(
      builder: (context) => OnboardingScreen(
        onGetStarted: () async {
          if (registrationGate != null) await registrationGate;
          if (context.mounted) await _open(context, 'Registration phone');
        },
        onLogIn: () => _open(context, 'Login phone'),
      ),
    ),
    providers: [
      BlocProvider<OnboardingBloc>(
        create: (_) => OnboardingBloc()..add(const OnboardingPrepared()),
      ),
    ],
    tier: tier,
    textScale: textScale,
    size: size,
    locale: locale,
  );
}

Future<void> _open(BuildContext context, String label) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(appBar: AppBar(title: Text(label))),
      ),
    );

Future<void> _tapLegal(WidgetTester tester, String label) async {
  final finder = find.descendant(
    of: find.byType(LegalFooter),
    matching: find.byType(RichText),
  );
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final text = paragraph.text.toPlainText();
  final start = text.indexOf(label);
  final box = paragraph
      .getBoxesForSelection(
        TextSelection(baseOffset: start, extentOffset: start + label.length),
      )
      .first;
  await tester.tapAt(paragraph.localToGlobal(box.toRect().center));
}

void main() {
  testWidgets('renders the hero, calls to action, socials and legal links', (
    tester,
  ) async {
    await _pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingHero), findsOneWidget);
    expect(find.text(_l10n.onboardingTitle), findsOneWidget);
    expect(find.text(_l10n.onboardingGetStarted), findsOneWidget);
    expect(find.text(_l10n.onboardingLogIn), findsOneWidget);
    expect(find.byTooltip(_l10n.onboardingGoogle), findsOneWidget);
    expect(find.byTooltip(_l10n.onboardingApple), findsOneWidget);
    expect(find.byTooltip(_l10n.onboardingFacebook), findsOneWidget);
    expect(find.byType(LegalFooter), findsOneWidget);
  });

  testWidgets('double tap opens registration once and back allows login', (
    tester,
  ) async {
    final registrationGate = Completer<void>();
    await _pumpScreen(tester, registrationGate: registrationGate.future);
    await tester.pumpAndSettle();
    final start = find.text(_l10n.onboardingGetStarted);
    await tester.tap(start);
    await tester.pump();
    await tester.tap(start);
    await tester.pump();
    registrationGate.complete();
    await tester.pumpAndSettle();

    expect(find.text('Registration phone'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(start, findsOneWidget);

    await tester.tap(find.text(_l10n.onboardingLogIn));
    await tester.pumpAndSettle();
    expect(find.text('Login phone'), findsOneWidget);
  });

  testWidgets('renders the reference button and text colours at 1.3x', (
    tester,
  ) async {
    await _pumpScreen(tester, textScale: 1.3);
    await tester.pumpAndSettle();

    final button = find.byType(FilledButton);
    final context = tester.element(button);
    final colors = context.colors;
    final typography = context.typography;
    _expectPalette(colors);
    _expectTypography(context);
    final material = tester.widget<Material>(
      find.descendant(of: button, matching: find.byType(Material)),
    );
    expect(material.color, colors.primary);
    expect(material.elevation, 0);
    final themeStyle = FilledButtonTheme.of(context).style!;
    expect(themeStyle.minimumSize!.resolve({})!.height, 52);
    _expectStyle(
      _renderedStyle(tester, _l10n.onboardingTitle),
      typography.headline,
      colors.textPrimary,
    );
    _expectStyle(
      _renderedStyle(tester, _l10n.onboardingGetStarted),
      typography.button,
      colors.onPrimary,
    );
    _expectStyle(
      _renderedStyle(tester, _l10n.onboardingHaveAccount),
      typography.body,
      colors.textSecondary,
    );
    _expectStyle(
      _renderedStyle(tester, _l10n.onboardingLogIn),
      typography.bodyStrong,
      colors.accent,
    );
    _expectFooterStyle(tester, context);
    expect(tester.takeException(), isNull);
  });

  for (final size in [DeviceMatrix.smallPhone, DeviceMatrix.largePhone]) {
    for (final locale in [const Locale('en'), const Locale('my')]) {
      testWidgets('fits ${size.width} dp at 1.3x in ${locale.languageCode}', (
        tester,
      ) async {
        await _pumpScreen(tester, textScale: 1.3, size: size, locale: locale);
        await tester.pumpAndSettle();
        final l10n = lookupAppLocalizations(locale);
        expect(find.text(l10n.onboardingTitle), findsOneWidget);
        expect(
          find.text(l10n.onboardingGetStarted).hitTestable(),
          findsOneWidget,
        );
        expect(find.byType(LegalFooter), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('social and legal buttons each show an availability notice', (
    tester,
  ) async {
    await _pumpScreen(tester);
    await tester.pumpAndSettle();
    for (final label in [
      _l10n.onboardingGoogle,
      _l10n.onboardingApple,
      _l10n.onboardingFacebook,
    ]) {
      await tester.tap(find.byTooltip(label));
      await _expectPlaceholder(tester);
    }
    for (final label in [_l10n.onboardingTerms, _l10n.onboardingPrivacy]) {
      await _tapLegal(tester, label);
      await _expectPlaceholder(tester);
    }
  });

  testWidgets('reduced motion shows the controls on the first frame', (
    tester,
  ) async {
    await _pumpScreen(tester, tier: MotionTier.minimal);
    final title = find.text(_l10n.onboardingTitle);
    expect(
      find.descendant(
        of: find.byType(StaggeredItem),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    expect(title.hitTestable(), findsOneWidget);
    expect(
      tester
          .widget<AnnotatedRegion<dynamic>>(
            find.ancestor(
              of: find.byType(OnboardingHero),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is AnnotatedRegion &&
                    widget.value == AppTheme.lightSystemBars,
              ),
            ),
          )
          .value,
      AppTheme.lightSystemBars,
    );
  });
}

TextStyle _renderedStyle(WidgetTester tester, String label) =>
    tester.renderObject<RenderParagraph>(find.text(label)).text.style!;

void _expectPalette(AppColors colors) {
  expect(colors.primary, const Color(0xFF55CFEA));
  expect(colors.onPrimary, const Color(0xFFFFFFFF));
  expect(colors.accent, const Color(0xFFEE4F9B));
  expect(colors.textPrimary, const Color(0xFF1F1B24));
  expect(colors.textSecondary, const Color(0xFF2B2730));
  expect(colors.textDisabled, const Color(0xFF9C99A3));
  expect(colors.authGradient.colors, const [
    Color(0xFFFCE4EE),
    Color(0xFFFDEEF4),
  ]);
}

void _expectTypography(BuildContext context) {
  final typography = context.typography;
  expect(typography.headline.fontSize, 28);
  expect(typography.headline.fontWeight, FontWeight.w700);
  expect(typography.headline.height, 1.15);
  expect(typography.button.fontSize, 14);
  expect(typography.button.fontWeight, FontWeight.w700);
  expect(typography.button.letterSpacing, 1);
  expect(typography.button.height, isNull);
  expect(typography.body.fontSize, 14);
  expect(typography.body.fontWeight, FontWeight.w400);
  expect(typography.bodyStrong.fontSize, 14);
  expect(typography.bodyStrong.fontWeight, FontWeight.w700);
  expect(typography.caption.fontSize, 11);
  expect(typography.caption.fontWeight, FontWeight.w400);
  expect(typography.caption.height, 1.35);
}

void _expectStyle(TextStyle rendered, TextStyle token, Color color) {
  expect(rendered.fontFamily, token.fontFamily);
  expect(rendered.fontSize, token.fontSize);
  expect(rendered.fontWeight, token.fontWeight);
  expect(rendered.letterSpacing, token.letterSpacing);
  expect(rendered.height, token.height);
  expect(rendered.color, color);
}

void _expectFooterStyle(WidgetTester tester, BuildContext context) {
  final footer =
      tester
              .renderObject<RenderParagraph>(
                find.descendant(
                  of: find.byType(LegalFooter),
                  matching: find.byType(RichText),
                ),
              )
              .text
          as TextSpan;
  final colors = context.colors;
  final caption = context.typography.caption;
  _expectStyle(footer.style!, caption, colors.textDisabled);
  final spans = <TextSpan>[];
  footer.visitChildren((span) {
    if (span is TextSpan) spans.add(span);
    return true;
  });
  for (final label in [_l10n.onboardingTerms, _l10n.onboardingPrivacy]) {
    final link = spans.singleWhere((span) => span.text == label);
    _expectStyle(link.style!, caption, colors.accent);
    expect(link.recognizer, isNotNull);
  }
}

Future<void> _expectPlaceholder(WidgetTester tester) async {
  await tester.pumpAndSettle();
  expect(find.text(_l10n.onboardingComingSoon), findsOneWidget);
  final context = tester.element(find.byType(LegalFooter));
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  await tester.pumpAndSettle();
}
