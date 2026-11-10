import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/core/theme/gradient_sampling.dart';
import 'package:jdonuts/core/widgets/legal_footer.dart';
import 'package:jdonuts/module/auth/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_actions.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_hero.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_login_prompt.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_title.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/social_login_row.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({
    required this.onGetStarted,
    required this.onLogIn,
    super.key,
  });

  final Future<void> Function() onGetStarted;
  final Future<void> Function() onLogIn;

  @override
  Widget build(BuildContext context) => _OnboardingEffects(
    onGetStarted: onGetStarted,
    onLogIn: onLogIn,
    child: AnnotatedRegion(
      value: AppTheme.lightSystemBars,
      child: Scaffold(
        backgroundColor: context.colors.surface.withValues(alpha: 0),
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: DecoratedBox(
          decoration: BoxDecoration(gradient: context.colors.authGradient),
          child: const StaggeredEntrance(
            itemCount: _OnboardingLayout.itemCount,
            child: _OnboardingLayout(),
          ),
        ),
      ),
    ),
  );
}

class _OnboardingEffects extends StatelessWidget {
  const _OnboardingEffects({
    required this.onGetStarted,
    required this.onLogIn,
    required this.child,
  });

  final Future<void> Function() onGetStarted;
  final Future<void> Function() onLogIn;
  final Widget child;

  Future<void> _open(OnboardingBloc bloc, OnboardingOpening opening) async {
    try {
      await switch (opening.action) {
        OnboardingAction.register => onGetStarted(),
        OnboardingAction.login => onLogIn(),
      };
    } finally {
      if (!bloc.isClosed) bloc.add(const OnboardingReturned());
    }
  }

  void _showNotice(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.onboardingComingSoon)),
      );
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) => current is OnboardingOpening,
        listener: (context, state) {
          if (state is OnboardingOpening) {
            unawaited(_open(context.read<OnboardingBloc>(), state));
          }
        },
      ),
      BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) =>
            previous is OnboardingReady &&
            current is OnboardingReady &&
            previous.noticeEpoch != current.noticeEpoch,
        listener: (context, state) => _showNotice(context),
      ),
    ],
    child: child,
  );
}

class _OnboardingLayout extends StatelessWidget {
  const _OnboardingLayout();

  static const itemCount = 8;
  static const _heroFraction = 0.56;
  static const _maxHeroHeight = 560.0;
  static const _minimumControlsHeight = 268.0;

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
          child: OnboardingHero(
            backgroundAtEdge: sampleLinearGradient(
              context.colors.authGradient,
              height / viewport,
            ),
          ),
        ),
        Positioned.fill(
          top: math.max(safeTop, height - context.spacing.sm),
          child: const SafeArea(top: false, child: _OnboardingControls()),
        ),
      ],
    );
  }

  double _heroHeight(BuildContext context, double viewport) {
    final safe = MediaQuery.paddingOf(context);
    final reserve = MediaQuery.textScalerOf(context).scale(
      _minimumControlsHeight,
    );
    final desired = math.min(
      viewport * _heroFraction,
      _maxHeroHeight,
    );
    return math.min(
      desired,
      math.max(safe.top, viewport - safe.bottom - reserve),
    );
  }
}

class _OnboardingControls extends StatelessWidget {
  const _OnboardingControls();

  void _select(BuildContext context, OnboardingAction action) =>
      context.read<OnboardingBloc>().add(OnboardingActionSelected(action));

  void _requestNotice(BuildContext context) => context
      .read<OnboardingBloc>()
      .add(const OnboardingPlaceholderRequested());

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

  Widget _content(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const StaggeredItem(index: 3, child: OnboardingTitle()),
      const Spacer(flex: 3),
      StaggeredItem(
        index: 4,
        child: OnboardingActions(
          onPressed: () => _select(context, OnboardingAction.register),
        ),
      ),
      StaggeredItem(
        index: 5,
        child: OnboardingLoginPrompt(
          onLogIn: () => _select(context, OnboardingAction.login),
        ),
      ),
      SizedBox(height: context.spacing.md),
      StaggeredItem(
        index: 6,
        child: SocialLoginRow(onUnavailable: () => _requestNotice(context)),
      ),
      const Spacer(flex: 2),
      StaggeredItem(index: 7, child: _legal(context)),
      SizedBox(height: context.spacing.lg),
    ],
  );

  Widget _legal(BuildContext context) {
    final l10n = context.l10n;
    return LegalFooter(
      before: l10n.onboardingLegalBefore,
      terms: l10n.onboardingTerms,
      between: l10n.onboardingLegalBetween,
      privacy: l10n.onboardingPrivacy,
      after: l10n.onboardingLegalAfter,
      onTerms: () => _requestNotice(context),
      onPrivacy: () => _requestNotice(context),
    );
  }
}
