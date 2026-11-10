import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/core/theme/gradient_sampling.dart';
import 'package:jdonuts/module/auth/presentation/bloc/welcome/welcome_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/widgets/welcome_actions.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/widgets/welcome_hero.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/widgets/welcome_title.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.onExplore,
    this.debugForceHeroFallback = false,
    super.key,
  });

  final Future<void> Function() onExplore;

  @visibleForTesting
  final bool debugForceHeroFallback;

  @override
  Widget build(BuildContext context) => _WelcomeEffects(
    onExplore: onExplore,
    child: AnnotatedRegion(
      value: AppTheme.lightSystemBars,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) unawaited(SystemNavigator.pop());
        },
        child: Scaffold(
          backgroundColor: context.colors.surface.withValues(alpha: 0),
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: DecoratedBox(
            decoration: BoxDecoration(gradient: context.colors.authGradient),
            child: StaggeredEntrance(
              itemCount: _WelcomeLayout.itemCount,
              child: _WelcomeLayout(
                debugForceHeroFallback: debugForceHeroFallback,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _WelcomeEffects extends StatelessWidget {
  const _WelcomeEffects({required this.onExplore, required this.child});

  final Future<void> Function() onExplore;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      BlocListener<WelcomeBloc, WelcomeState>(
        listenWhen: (previous, current) => current is WelcomeExploring,
        listener: (context, state) {
          unawaited(onExplore());
        },
        child: child,
      );
}

class _WelcomeLayout extends StatelessWidget {
  const _WelcomeLayout({required this.debugForceHeroFallback});

  static const itemCount = 6;
  static const _heroFraction = 0.72;
  static const _shortHeroFraction = 0.58;
  static const _maxHeroHeight = 640.0;
  static const _minimumControlsHeight = 200.0;
  static const _titleSlot = 4;
  static const _buttonSlot = 5;

  final bool debugForceHeroFallback;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) =>
        _placeContent(context, constraints.maxHeight),
  );

  Widget _placeContent(BuildContext context, double viewport) {
    final height = _heroHeight(context, viewport);
    final safeTop = MediaQuery.paddingOf(context).top;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: height,
          child: WelcomeHero(
            backgroundAtEdge: sampleLinearGradient(
              context.colors.authGradient,
              height / viewport,
            ),
            debugForceFallback: debugForceHeroFallback,
          ),
        ),
        Positioned.fill(
          top: math.max(safeTop, height - context.spacing.xl),
          child: const SafeArea(top: false, child: _WelcomeControls()),
        ),
      ],
    );
  }

  double _heroHeight(BuildContext context, double viewport) {
    final safe = MediaQuery.paddingOf(context);
    final layout = context.layout;
    final reserve = MediaQuery.textScalerOf(context).scale(
      _minimumControlsHeight,
    );
    final fraction = layout.isShortHeight ? _shortHeroFraction : _heroFraction;
    final desired = math.min(viewport * fraction, _maxHeroHeight);
    return math.min(
      desired,
      math.max(safe.top, viewport - safe.bottom - reserve),
    );
  }
}

class _WelcomeControls extends StatelessWidget {
  const _WelcomeControls();

  void _explore(BuildContext context) =>
      context.read<WelcomeBloc>().add(const WelcomeExploreSelected());

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.xl),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: IntrinsicHeight(child: _content(context)),
      ),
    ),
  );

  Widget _content(BuildContext context) {
    final short = context.layout.isShortHeight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StaggeredItem(
          index: _WelcomeLayout._titleSlot,
          child: WelcomeTitle(),
        ),
        if (short)
          SizedBox(height: context.spacing.xl)
        else
          const Spacer(),
        StaggeredItem(
          index: _WelcomeLayout._buttonSlot,
          child: WelcomeActions(onPressed: () => _explore(context)),
        ),
        SizedBox(height: context.spacing.lg),
      ],
    );
  }
}
