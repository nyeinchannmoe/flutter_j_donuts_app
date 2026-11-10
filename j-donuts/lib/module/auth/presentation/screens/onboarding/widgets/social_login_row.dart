import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/module/auth/presentation/screens/onboarding/widgets/onboarding_press_feedback.dart';

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

class _SocialButton extends StatefulWidget {
  const _SocialButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  final _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OnboardingPressFeedback(
    states: _states,
    child: Semantics(
      button: true,
      label: widget.label,
      child: Tooltip(
        excludeFromSemantics: true,
        message: widget.label,
        child: Material(
          type: MaterialType.transparency,
          child: InkResponse(
            statesController: _states,
            onTap: widget.onTap,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: kMinInteractiveDimension,
              child: Center(
                child: SvgPicture.asset(
                  '${SocialLoginRow.assetFolder}/${widget.asset}.svg',
                  width: context.iconSizes.brandMark,
                  height: context.iconSizes.brandMark,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
