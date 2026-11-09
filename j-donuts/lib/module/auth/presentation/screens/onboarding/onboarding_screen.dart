import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/pop_in.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/widgets/buttons/app_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    required this.onGetStarted,
    required this.onLogIn,
    super.key,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(gradient: context.colors.authGradient),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.layout.horizontalGutter),
          child: StaggeredEntrance(
            itemCount: _OnboardingBody.itemCount,
            child: _OnboardingBody(
              onGetStarted: onGetStarted,
              onLogIn: onLogIn,
            ),
          ),
        ),
      ),
    ),
  );
}

class _OnboardingBody extends StatelessWidget {
  const _OnboardingBody({required this.onGetStarted, required this.onLogIn});

  static const int itemCount = 3;

  final VoidCallback onGetStarted;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          child: Center(child: PopIn(child: _DonutMark())),
        ),
        StaggeredItem(
          index: 0,
          child: Text(
            l10n.onboardingTitle,
            textAlign: TextAlign.center,
            style: context.typography.display,
          ),
        ),
        SizedBox(height: spacing.xxl),
        StaggeredItem(
          index: 1,
          child: AppButton(
            label: l10n.onboardingGetStarted,
            onPressed: onGetStarted,
          ),
        ),
        SizedBox(height: spacing.md),
        StaggeredItem(index: 2, child: _LogInPrompt(onLogIn: onLogIn)),
      ],
    );
  }
}

class _DonutMark extends StatelessWidget {
  const _DonutMark();

  @override
  Widget build(BuildContext context) => Icon(
    Icons.donut_large_rounded,
    size: context.iconSizes.illustration,
    color: context.colors.accent,
  );
}

class _LogInPrompt extends StatelessWidget {
  const _LogInPrompt({required this.onLogIn});

  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(context.l10n.onboardingHaveAccount, style: context.typography.body),
      TextButton(
        onPressed: onLogIn,
        child: Text(
          context.l10n.onboardingLogIn,
          style: context.typography.bodyStrong.copyWith(
            color: context.colors.accent,
          ),
        ),
      ),
    ],
  );
}
