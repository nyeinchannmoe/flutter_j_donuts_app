import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_hero.dart';

/// Keeps the first onboarding frame behind the same gradient until the
/// decoded hero is in Flutter's image cache.
class OnboardingEntry extends StatefulWidget {
  const OnboardingEntry({required this.child, super.key});

  final Widget child;

  @override
  State<OnboardingEntry> createState() => _OnboardingEntryState();
}

class _OnboardingEntryState extends State<OnboardingEntry> {
  bool _started = false;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    await precacheImage(
      OnboardingHero.imageFor(context),
      context,
      onError: (_, _) {
        // The hero paints its bundled-image fallback if decoding fails.
      },
    );
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) => _ready
      ? widget.child
      : AnnotatedRegion(
          value: AppTheme.lightSystemBars,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: context.colors.authGradient),
            child: const SizedBox.expand(),
          ),
        );
}
