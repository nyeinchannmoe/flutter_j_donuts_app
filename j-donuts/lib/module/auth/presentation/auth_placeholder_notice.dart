import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

/// Single placeholder for Google, Apple, Facebook, Terms and Privacy.
void showAuthPlaceholderNotice(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(context.l10n.onboardingComingSoon)),
    );
}
