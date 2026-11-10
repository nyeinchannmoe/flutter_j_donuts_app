import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/widgets/buttons/pressable_scale.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({required this.onUnavailable, super.key});

  static const assetFolder = 'assets/images/onboarding';

  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: context.spacing.lg,
    children: [
      _SocialButton(
        asset: 'google',
        label: context.l10n.onboardingGoogle,
        onTap: onUnavailable,
      ),
      _SocialButton(
        asset: 'apple',
        label: context.l10n.onboardingApple,
        onTap: onUnavailable,
      ),
      _SocialButton(
        asset: 'facebook',
        label: context.l10n.onboardingFacebook,
        onTap: onUnavailable,
      ),
    ],
  );
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => PressableScale(
    onTap: onTap,
    child: Semantics(
      button: true,
      label: label,
      child: Tooltip(
        excludeFromSemantics: true,
        message: label,
        child: SizedBox.square(
          dimension: kMinInteractiveDimension,
          child: Center(
            child: SvgPicture.asset(
              '${SocialLoginRow.assetFolder}/$asset.svg',
              width: context.iconSizes.brandMark,
              height: context.iconSizes.brandMark,
            ),
          ),
        ),
      ),
    ),
  );
}
