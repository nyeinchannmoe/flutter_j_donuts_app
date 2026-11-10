import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_disc_entrance_painter.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_hero_painter.dart';

class OnboardingHero extends StatefulWidget {
  const OnboardingHero({required this.backgroundAtEdge, super.key});

  static const _maxDecodeWidth = 1080;
  static const asset = 'assets/images/onboarding/onboarding_hero.png';

  final Color backgroundAtEdge;

  static ImageProvider<Object> imageFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final density = MediaQuery.devicePixelRatioOf(context);
    return ResizeImage(
      const AssetImage(asset),
      width: (width * density).ceil().clamp(1, _maxDecodeWidth),
    );
  }

  @override
  State<OnboardingHero> createState() => _OnboardingHeroState();
}

class _OnboardingHeroState extends State<OnboardingHero>
    with SingleTickerProviderStateMixin {
  static const _discSlots = 3;
  static const _fadeStart = 0.75;

  ImageStream? _stream;
  ImageInfo? _image;
  late final AnimationController _frame = AnimationController(
    vsync: this,
    duration: MotionTokens.micro,
  );
  late final _listener = ImageStreamListener(_receiveImage, onError: _fail);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stream = OnboardingHero.imageFor(context).resolve(
      createLocalImageConfiguration(context),
    );
    if (stream.key == _stream?.key) return;
    _stream?.removeListener(_listener);
    _stream = stream..addListener(_listener);
  }

  void _receiveImage(ImageInfo image, bool synchronousCall) {
    _replace(image);
    if (!synchronousCall) _repaint();
  }

  void _fail(Object error, StackTrace? stackTrace) {
    _replace(null);
    _repaint();
  }

  void _repaint() {
    _frame.reset();
    unawaited(_frame.forward());
  }

  void _replace(ImageInfo? image) {
    _image?.dispose();
    _image = image;
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    _image?.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _frame,
    builder: (context, _) => RepaintBoundary(
      child: ExcludeSemantics(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _artwork(context),
            DecoratedBox(decoration: BoxDecoration(gradient: _fade())),
          ],
        ),
      ),
    ),
  );

  Widget _artwork(BuildContext context) {
    final image = _image?.image;
    if (image == null) {
      return StaggeredItem(
        index: 0,
        horizontalDrift: true,
        child: CustomPaint(
          painter: OnboardingHeroPainter(
            colors: context.colors,
            glazeShadow: context.colors.accent,
          ),
        ),
      );
    }
    return CustomPaint(
      painter: OnboardingDiscEntrancePainter(
        image: image,
        tint: context.colors.surface,
        tracks: List.generate(
          _discSlots,
          (index) => StaggeredEntrance.animationFor(context, index),
        ),
      ),
    );
  }

  LinearGradient _fade() => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      widget.backgroundAtEdge.withValues(alpha: 0),
      widget.backgroundAtEdge,
    ],
    stops: const [_fadeStart, 1],
  );
}
