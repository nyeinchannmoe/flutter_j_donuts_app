import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';

class LegalFooter extends StatefulWidget {
  const LegalFooter({
    required this.before,
    required this.terms,
    required this.between,
    required this.privacy,
    required this.after,
    required this.onTerms,
    required this.onPrivacy,
    super.key,
  });

  final String before;
  final String terms;
  final String between;
  final String privacy;
  final String after;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  State<LegalFooter> createState() => _LegalFooterState();
}

class _LegalFooterState extends State<LegalFooter> {
  late final _terms = TapGestureRecognizer()..onTap = () => widget.onTerms();
  late final _privacy = TapGestureRecognizer()
    ..onTap = () => widget.onPrivacy();
  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final caption = context.typography.caption.copyWith(
      color: context.colors.textDisabled,
    );
    final link = caption.copyWith(
      color: context.colors.accent,
    );
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: widget.before),
          TextSpan(text: widget.terms, style: link, recognizer: _terms),
          TextSpan(text: widget.between),
          TextSpan(
            text: widget.privacy,
            style: link,
            recognizer: _privacy,
          ),
          TextSpan(text: widget.after),
        ],
      ),
      textAlign: TextAlign.center,
      style: caption,
    );
  }
}
