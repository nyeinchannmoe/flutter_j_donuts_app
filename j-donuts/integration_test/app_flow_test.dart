import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jdonuts/bootstrap.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/data/datasources/fake_otp_gateway.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/otp_verification/otp_verification_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/phone_entry/phone_entry_screen.dart';
import 'package:jdonuts/module/auth/presentation/screens/registration_name/registration_name_screen.dart';

const Duration _step = Duration(milliseconds: 100);
const Duration _timeout = Duration(seconds: 20);

Finder _button(String label) => find.byWidgetPredicate(
  (widget) => widget is AppButton && widget.label == label,
);

extension on WidgetTester {
  /// Pumps frames until [finder] matches. Home runs ambient animation, so
  /// pumpAndSettle would never return.
  Future<void> pumpUntilFound(Finder finder) async {
    final deadline = DateTime.now().add(_timeout);
    while (finder.evaluate().isEmpty) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for $finder');
      }
      await pump(_step);
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final l10n = lookupAppLocalizations(const Locale('en'));

  testWidgets('a fresh install signs up through the auth flow', (
    tester,
  ) async {
    final testErrorHandler = FlutterError.onError;
    await bootstrap();
    FlutterError.onError = testErrorHandler;

    await tester.pumpUntilFound(find.byType(OnboardingScreen));
    await tester.tap(_button(l10n.onboardingGetStarted));

    await tester.pumpUntilFound(find.byType(PhoneEntryScreen));
    await tester.enterText(find.byType(TextField), '9123456789');
    await tester.pump();
    await tester.tap(_button(l10n.actionContinue));

    await tester.pumpUntilFound(find.byType(OtpVerificationScreen));
    await tester.enterText(find.byType(TextField), FakeOtpGateway.demoCode);
    await tester.pump();
    await tester.tap(_button(l10n.actionContinue));

    await tester.pumpUntilFound(find.byType(RegistrationNameScreen));
  });
}
