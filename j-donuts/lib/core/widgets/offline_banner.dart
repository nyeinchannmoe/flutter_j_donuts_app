import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/connectivity/connection_status.dart';
import 'package:jdonuts/core/connectivity/connectivity_cubit.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/motion/motion_tokens.dart';

/// Small banner that slides down while the device is offline. Mounted once
/// above the router so every screen shares it.
class OfflineBannerHost extends StatelessWidget {
  const OfflineBannerHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      BlocSelector<ConnectivityCubit, ConnectionStatus, bool>(
        selector: (status) => status.isOffline,
        builder: (context, isOffline) => Column(
          children: [
            _AnimatedBanner(visible: isOffline),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: isOffline,
                child: child,
              ),
            ),
          ],
        ),
      );
}

class _AnimatedBanner extends StatelessWidget {
  const _AnimatedBanner({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final profile = context.motion;
    return AnimatedSize(
      duration: profile.scaleDuration(MotionTokens.standard),
      curve: MotionTokens.standardCurve,
      alignment: Alignment.topCenter,
      child: visible
          ? const _BannerContent()
          : const SizedBox(width: double.infinity),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      liveRegion: true,
      child: ColoredBox(
        color: colors.offlineBanner,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.lg,
              vertical: context.spacing.sm,
            ),
            child: _message(context),
          ),
        ),
      ),
    );
  }

  Widget _message(BuildContext context) {
    final color = context.colors.onOfflineBanner;
    return Row(
      spacing: context.spacing.sm,
      children: [
        Icon(
          Icons.cloud_off_outlined,
          size: context.iconSizes.sm,
          color: color,
        ),
        Expanded(
          child: Text(
            context.l10n.offlineBanner,
            style: context.typography.caption.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
