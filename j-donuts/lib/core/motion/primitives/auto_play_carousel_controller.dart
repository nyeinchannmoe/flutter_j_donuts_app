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

  /// Applies [profile] and starts or stops auto-play accordingly.
  void updateProfile(MotionProfile profile) {
    _profile = profile;
    profile.allowsAmbient ? _start() : _stop();
  }

  /// Call when the user starts interacting with the carousel.
  void pauseForInteraction() {
    _stop();
    _resumeTimer?.cancel();
    _resumeTimer = Timer(resumeDelay, () => updateProfile(_profile));
  }

  void _start() {
    if (pageCount < 2 || isPlaying) return;
    _timer = Timer.periodic(interval, (_) => _advance());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _advance() {
    if (!pageController.hasClients) return;
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
