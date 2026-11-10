import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/responsive/layout_metrics.dart';
import 'package:jdonuts/core/widgets/hero_edge_fade.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/widgets/welcome_hero_painter.dart';
import 'package:jdonuts/module/auth/presentation/screens/welcome/widgets/welcome_tile_entrance_painter.dart';

class WelcomeHero extends StatefulWidget {
  const WelcomeHero({
    required this.backgroundAtEdge,
    this.debugForceFallback = false,
    super.key,
  });

  static const _maxDecodeWidth = 1080;
  static const asset = 'assets/images/welcome/welcome_hero.png';

  final Color backgroundAtEdge;

  @visibleForTesting
  final bool debugForceFallback;

  static ImageProvider<Object> imageFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final density = MediaQuery.devicePixelRatioOf(context);
    return ResizeImage(
      const AssetImage(asset),
      width: (width * density).ceil().clamp(1, _maxDecodeWidth),
    );
  }

  @override
  State<WelcomeHero> createState() => _WelcomeHeroState();
}

class _WelcomeHeroState extends State<WelcomeHero>
    with SingleTickerProviderStateMixin {
  static const _tileSlots = 4;

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
    if (widget.debugForceFallback) {
      _replace(null);
      return;
    }
    final stream = WelcomeHero.imageFor(context).resolve(
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
            HeroEdgeFade(color: widget.backgroundAtEdge),
          ],
        ),
      ),
    ),
  );

  Widget _artwork(BuildContext context) {
    final image = _image?.image;
    if (image == null) {
      return CustomPaint(
        painter: WelcomeHeroPainter(colors: context.colors),
      );
    }
    final travel =
        MotionTokens.travelMedium * LayoutMetrics.of(context).motionScale;
    return CustomPaint(
      painter: WelcomeTileEntrancePainter(
        image: image,
        tint: context.colors.surface,
        travel: travel,
        tracks: List.generate(
          _tileSlots,
          (index) => StaggeredEntrance.animationFor(context, index),
        ),
      ),
    );
  }
}
