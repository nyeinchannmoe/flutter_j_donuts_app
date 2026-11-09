import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/motion/primitives/auto_play_carousel_controller.dart';

void main() {
  group('AutoPlayCarouselController', () {
    test('defaults viewportFraction to a full-width page', () {
      final carousel = AutoPlayCarouselController(pageCount: 2);
      addTearDown(carousel.dispose);
      expect(carousel.viewportFraction, 1);
      expect(carousel.pageController.viewportFraction, 1);
    });

    test('honours a custom viewportFraction for peek layouts', () {
      final carousel = AutoPlayCarouselController(
        pageCount: 3,
        viewportFraction: 0.88,
      );
      addTearDown(carousel.dispose);
      expect(carousel.viewportFraction, 0.88);
      expect(carousel.pageController.viewportFraction, 0.88);
    });

    test('does not auto-play on the minimal motion profile', () {
      final carousel = AutoPlayCarouselController(pageCount: 3);
      addTearDown(carousel.dispose);
      carousel.updateProfile(MotionProfile.minimal);
      expect(carousel.isPlaying, isFalse);
    });

    test('auto-plays when ambient motion is allowed and pageCount is 2+', () {
      final carousel = AutoPlayCarouselController(pageCount: 3);
      addTearDown(carousel.dispose);
      carousel.updateProfile(MotionProfile.full);
      expect(carousel.isPlaying, isTrue);
    });
  });
}
