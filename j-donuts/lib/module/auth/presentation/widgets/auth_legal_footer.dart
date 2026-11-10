import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/legal_footer.dart';
import 'package:jdonuts/module/auth/presentation/auth_placeholder_notice.dart';

/// Terms and Privacy footer wired to [showAuthPlaceholderNotice].
class AuthLegalFooter extends StatelessWidget {
  const AuthLegalFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LegalFooter(
      before: l10n.onboardingLegalBefore,
      terms: l10n.onboardingTerms,
      between: l10n.onboardingLegalBetween,
      privacy: l10n.onboardingPrivacy,
      after: l10n.onboardingLegalAfter,
      onTerms: () => showAuthPlaceholderNotice(context),
      onPrivacy: () => showAuthPlaceholderNotice(context),
    );
  }
}
