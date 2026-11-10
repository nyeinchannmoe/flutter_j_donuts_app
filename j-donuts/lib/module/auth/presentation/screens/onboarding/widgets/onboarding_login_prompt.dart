import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

class OnboardingLoginPrompt extends StatelessWidget {
  const OnboardingLoginPrompt({required this.onLogIn, super.key});

  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        context.l10n.onboardingHaveAccount,
        style: context.typography.body.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
      TextButton(
        style: TextButton.styleFrom(
          foregroundColor: context.colors.accent,
          padding: EdgeInsetsDirectional.only(
            start: context.spacing.xs,
            end: context.spacing.md,
          ),
          minimumSize: Size(0, context.spacing.xxl + context.spacing.sm),
          textStyle: context.typography.bodyStrong,
        ),
        onPressed: onLogIn,
        child: Text(context.l10n.onboardingLogIn),
      ),
    ],
  );
}
