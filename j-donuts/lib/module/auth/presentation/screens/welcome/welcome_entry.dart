import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/module/auth/presentation/bloc/welcome/welcome_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/widgets/welcome_hero.dart';

/// Holds the auth gradient until the welcome Bloc reports the hero is ready.
class WelcomeEntry extends StatelessWidget {
  const WelcomeEntry({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<WelcomeBloc, WelcomeState>(
        buildWhen: (previous, current) =>
            previous is WelcomePreparing != current is WelcomePreparing,
        builder: (context, state) {
          if (state is! WelcomePreparing) return child;
          return const _PreparingShell();
        },
      );
}

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
      WelcomeHero.imageFor(context),
      context,
      onError: (_, _) {
        // The hero paints its vector fallback if decoding fails.
      },
    );
    if (!mounted) return;
    context.read<WelcomeBloc>().add(const WelcomePrepared());
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
