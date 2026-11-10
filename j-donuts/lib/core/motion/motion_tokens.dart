import 'package:flutter/animation.dart';

/// The only place that defines motion durations and curves.
abstract final class MotionTokens {
  static const Duration micro = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 260);
  static const Duration emphasized = Duration(milliseconds: 420);
  static const Duration entrance = Duration(milliseconds: 560);
  static const Duration countUp = Duration(milliseconds: 1400);
  static const Duration ambient = Duration(milliseconds: 1800);
  static const Duration shimmer = Duration(milliseconds: 1300);
  static const Duration carouselInterval = Duration(seconds: 4);
  static const Duration carouselResumeDelay = Duration(seconds: 6);

  /// Fallback used by the minimal tier instead of skipping entirely.
  static const Duration minimalFade = Duration(milliseconds: 120);

  static const Curve standardCurve = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.easeOutCubic;
  static const Curve accelerate = Curves.easeInCubic;
  static const Curve emphasizedCurve = Curves.easeOutQuart;
  static const Curve popOvershoot = Curves.easeOutBack;
  static const Curve shake = Curves.linear;
  static const Curve spring = Curves.elasticOut;

  /// Delay between consecutive staggered items.
  static const Duration staggerStep = Duration(milliseconds: 70);
  static const int maxStaggeredItems = 8;
  static const int reducedStaggeredItems = 3;

  /// Fraction of the entrance a single staggered item occupies.
  static const double staggerItemSpan = 0.55;

  /// Travel distances in logical pixels, multiplied by motionScale.
  static const double travelMedium = 24;
  static const double onboardingDiscTravel = 16;

  static const double pressedScale = 0.96;
  static const double popStartScale = 0.6;
  static const double pulseScale = 1.06;
  static const double fadeThroughStartScale = 0.94;

  static const double shakeAmplitude = 10;
  static const int shakeCycles = 3;

  /// Maximum perspective tilt in radians.
  static const double maxTilt = 0.18;
  static const double perspectiveDepth = 0.0012;

  /// Multiplier the reduced tier applies to every duration.
  static const double reducedDurationFactor = 0.6;
}
