import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/module/auth/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_hero.dart';

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
          return const _PreparingShell();
        },
      );
}

/// Precaches the hero after the first frame so MediaQuery is safe to read.
class _PreparingShell extends StatefulWidget {
  const _PreparingShell();

  @override
  State<_PreparingShell> createState() => _PreparingShellState();
}

class _PreparingShellState extends State<_PreparingShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_prepare());
    });
  }

  Future<void> _prepare() async {
    await precacheImage(
      OnboardingHero.imageFor(context),
      context,
      onError: (_, _) {
        // The hero paints its bundled-image fallback if decoding fails.
      },
    );
    if (!mounted) return;
    context.read<OnboardingBloc>().add(const OnboardingPrepared());
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion(
    value: AppTheme.lightSystemBars,
    child: DecoratedBox(
      decoration: BoxDecoration(gradient: context.colors.authGradient),
      child: const SizedBox.expand(),
    ),
  );
}
