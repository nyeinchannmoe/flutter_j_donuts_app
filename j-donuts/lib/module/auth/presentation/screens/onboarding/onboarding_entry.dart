import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/module/auth/presentation/bloc/onboarding/onboarding_bloc.dart';

/// Holds the auth gradient until the onboarding Bloc reports the hero is ready.
class OnboardingEntry extends StatelessWidget {
  const OnboardingEntry({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<OnboardingBloc, OnboardingState>(
        buildWhen: (previous, current) =>
            previous is OnboardingPreparing != current is OnboardingPreparing,
        builder: (context, state) {
          if (state is! OnboardingPreparing) return child;
          return AnnotatedRegion(
            value: AppTheme.lightSystemBars,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: context.colors.authGradient),
              child: const SizedBox.expand(),
            ),
          );
        },
      );
}
