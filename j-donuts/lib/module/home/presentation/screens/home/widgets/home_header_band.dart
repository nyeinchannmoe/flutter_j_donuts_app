import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/banner_carousel.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/member_header.dart';

/// Wave depth as a multiple of the xl spacing token.
const double _waveDepthFactor = 1.35;

/// Extra space under the banners so the wave does not clip card corners.
const double _waveClearanceFactor = 0.55;

/// Peach wash wrapping the member header and promo carousel, ending in a
/// soft downward curve into the white content plane.
class HomeHeaderBand extends StatelessWidget {
  const HomeHeaderBand({required this.onNotificationsPressed, super.key});

  final VoidCallback onNotificationsPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final topInset = MediaQuery.paddingOf(context).top;
    final waveDepth = spacing.xl * _waveDepthFactor;
    return ClipPath(
      clipper: _HeaderWashClipper(waveDepth: waveDepth),
      child: ColoredBox(
        color: context.colors.headerWash,
        child: Padding(
          padding: EdgeInsets.only(
            top: topInset + spacing.sm,
            bottom: waveDepth + spacing.xl * _waveClearanceFactor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MemberHeader(onNotificationsPressed: onNotificationsPressed),
              SizedBox(height: spacing.lg),
              const BannerCarousel(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderWashClipper extends CustomClipper<Path> {
  const _HeaderWashClipper({required this.waveDepth});

  final double waveDepth;

  @override
  Path getClip(Size size) {
    final baseY = size.height - waveDepth;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, baseY)
      ..quadraticBezierTo(size.width / 2, size.height, 0, baseY)
      ..close();
  }

  @override
  bool shouldReclip(covariant _HeaderWashClipper oldClipper) =>
      oldClipper.waveDepth != waveDepth;
}
