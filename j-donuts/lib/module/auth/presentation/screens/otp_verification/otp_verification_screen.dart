import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/motion/primitives/staggered_entrance.dart';
import 'package:jdonuts/core/widgets/scaffold/step_page_scaffold.dart';
import 'package:jdonuts/module/auth/presentation/bloc/otp_verification/otp_verification_bloc.dart';
import 'package:jdonuts/module/auth/presentation/screens/otp_verification/widgets/otp_code_block.dart';
import 'package:jdonuts/module/auth/presentation/screens/otp_verification/widgets/otp_resend_block.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_legal_footer.dart';
import 'package:jdonuts/module/auth/presentation/widgets/auth_step_progress.dart';

/// Code entry. Returning members are moved on by the router as soon as the
/// session is authenticated; new members continue via [onNewMemberVerified].
class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({
    required this.phoneE164,
    required this.onNewMemberVerified,
    super.key,
  });

  final String phoneE164;
  final VoidCallback onNewMemberVerified;

  @override
  Widget build(BuildContext context) =>
      BlocListener<OtpVerificationBloc, OtpVerificationState>(
        listenWhen: (previous, current) =>
            current.verifiedIsRegistered == false &&
            previous.verifiedIsRegistered != false,
        listener: (context, _) => onNewMemberVerified(),
        child: StepPageScaffold(
          title: context.l10n.otpTitle,
          onBack: () => Navigator.maybePop(context),
          progress: const AuthStepProgress(step: 2),
          content: _OtpBody(phoneE164: phoneE164),
          supportingContent: const AuthLegalFooter(),
        ),
      );
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
