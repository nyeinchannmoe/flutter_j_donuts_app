import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

class LegalFooter extends StatefulWidget {
  const LegalFooter({required this.onUnavailable, super.key});

  final VoidCallback onUnavailable;

  @override
  State<LegalFooter> createState() => _LegalFooterState();
}

class _LegalFooterState extends State<LegalFooter> {
  late final _terms = TapGestureRecognizer()..onTap = _showPlaceholder;
  late final _privacy = TapGestureRecognizer()..onTap = _showPlaceholder;

  void _showPlaceholder() => widget.onUnavailable();

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final caption = context.typography.caption;
    final link = caption.copyWith(color: context.colors.accent);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: l10n.onboardingLegalBefore),
          TextSpan(text: l10n.onboardingTerms, style: link, recognizer: _terms),
          TextSpan(text: l10n.onboardingLegalBetween),
          TextSpan(
            text: l10n.onboardingPrivacy,
            style: link,
            recognizer: _privacy,
          ),
          TextSpan(text: l10n.onboardingLegalAfter),
        ],
      ),
      textAlign: TextAlign.center,
      style: caption.copyWith(
        color: context.colors.textDisabled,
      ),
    );
  }
}
