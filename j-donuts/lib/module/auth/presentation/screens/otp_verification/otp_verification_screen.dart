import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/morphing_progress_ring.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/widgets/legal_footer.dart';
import 'package:jdonuts/core/widgets/scaffold/step_page_scaffold.dart';
import 'package:jdonuts/module/auth/presentation/bloc/otp_verification/otp_verification_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/otp_verification/widgets/otp_code_block.dart';
import 'package:jdonuts/module/auth/presentation/screens/otp_verification/widgets/otp_resend_block.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_scaffold.dart';

/// Code entry. Returning members are moved on by the router as soon as the
/// session is authenticated; new members continue via [onNewMemberVerified].
class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({
    required this.phoneE164,
    required this.onNewMemberVerified,
    this.existingAccountOnly = false,
    super.key,
  });

  final String phoneE164;
  final bool existingAccountOnly;
  final VoidCallback onNewMemberVerified;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final extent = context.iconSizes.lg - context.spacing.xxs;
    return BlocListener<OtpVerificationBloc, OtpVerificationState>(
      listenWhen: (previous, current) =>
          current.verifiedIsRegistered == false &&
          previous.verifiedIsRegistered != false,
      listener: (context, _) => onNewMemberVerified(),
      child: StepPageScaffold(
        title: context.l10n.otpTitle,
        onBack: () => Navigator.maybePop(context),
        progress: MorphingProgressRing.steps(
          step: 2,
          totalSteps: authStepCount,
          extent: extent,
          trackColor: colors.tierColors.last,
          gradientColors: [colors.accent, colors.accent],
          checkColor: colors.onPrimary,
        ),
        content: _OtpBody(phoneE164: phoneE164),
        supportingContent: _legal(context),
      ),
    );
  }

  Widget _legal(BuildContext context) {
    final l10n = context.l10n;
    void showNotice() => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.onboardingComingSoon)),
    );
    return LegalFooter(
      before: l10n.onboardingLegalBefore,
      terms: l10n.onboardingTerms,
      between: l10n.onboardingLegalBetween,
      privacy: l10n.onboardingPrivacy,
      after: l10n.onboardingLegalAfter,
      onTerms: showNotice,
      onPrivacy: showNotice,
    );
  }
}

class _OtpBody extends StatelessWidget {
  const _OtpBody({required this.phoneE164});

  final String phoneE164;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return StaggeredEntrance(
      itemCount: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StaggeredItem(
            index: 0,
            child: Text(
              context.l10n.otpSubtitle(phoneE164),
              style: context.typography.body.copyWith(
                color: context.colors.textDisabled,
              ),
            ),
          ),
          SizedBox(height: spacing.xxl),
          const StaggeredItem(index: 1, child: OtpCodeBlock()),
          SizedBox(height: spacing.xl),
          const StaggeredItem(index: 2, child: OtpResendBlock()),
        ],
      ),
    );
  }
}
