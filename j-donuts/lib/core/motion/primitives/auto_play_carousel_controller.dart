import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Timer-driven page advance for a PageView.
///
/// Auto-play is ambient motion: it runs only when the profile allows it,
/// pauses while the user drags and resumes after a quiet period.
class AutoPlayCarouselController {
  AutoPlayCarouselController({
    required this.pageCount,
    this.interval = MotionTokens.carouselInterval,
    this.resumeDelay = MotionTokens.carouselResumeDelay,
    this.viewportFraction = 1,
  }) : pageController = PageController(viewportFraction: viewportFraction);

  final int pageCount;
  final Duration interval;
  final Duration resumeDelay;
  final double viewportFraction;
  final PageController pageController;

  Timer? _timer;
  Timer? _resumeTimer;
  MotionProfile _profile = MotionProfile.full;

  bool get isPlaying => _timer?.isActive ?? false;

  bool _tickersEnabled = true;

  /// Applies [profile] and starts or stops auto-play accordingly.
  void updateProfile(MotionProfile profile, {bool tickersEnabled = true}) {
    _profile = profile;
    _tickersEnabled = tickersEnabled;
    _syncPlayback();
  }

  /// Call when the user starts interacting with the carousel.
  void pauseForInteraction() {
    _stop(settle: true);
    _resumeTimer?.cancel();
    _resumeTimer = Timer(
      resumeDelay,
      () => updateProfile(_profile, tickersEnabled: _tickersEnabled),
    );
  }

  void _syncPlayback() {
    final shouldPlay =
        _tickersEnabled && _profile.allowsAmbient && pageCount >= 2;
    if (shouldPlay) {
      _start();
    } else {
      _stop(settle: true);
    }
  }

  void _start() {
    if (isPlaying) return;
    _timer = Timer.periodic(interval, (_) => _advance());
  }

  void _stop({bool settle = false}) {
    _timer?.cancel();
    _timer = null;
    if (!settle || !pageController.hasClients || pageCount < 1) return;
    final page = pageController.page?.round() ?? 0;
    pageController.jumpToPage(page.clamp(0, pageCount - 1));
  }

  void _advance() {
    if (!_tickersEnabled || !pageController.hasClients) return;
    final current = pageController.page?.round() ?? 0;
    unawaited(
      pageController.animateToPage(
        (current + 1) % pageCount,
        duration: _profile.scaleDuration(MotionTokens.emphasized),
        curve: MotionTokens.standardCurve,
      ),
    );
  }

  void dispose() {
    _stop();
    _resumeTimer?.cancel();
    pageController.dispose();
  }
}
