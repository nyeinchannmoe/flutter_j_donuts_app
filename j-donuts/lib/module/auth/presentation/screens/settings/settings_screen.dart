import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/core/locale/locale_cubit.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';
import 'package:jdonuts/module/auth/presentation/bloc/session/session_bloc.dart';

/// Language choice and sign out. Both act on app-level state, so this
/// screen reads the global LocaleCubit and SessionBloc.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        title: Text(l10n.navSettings, style: context.typography.title),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: context.spacing.md),
        children: [
          ListTile(
            title: Text(
              l10n.settingsLanguage,
              style: context.typography.subtitle,
            ),
          ),
          const _LanguageOptions(),
          const Divider(),
          const _LogOutTile(),
        ],
      ),
    );
  }
}

class _LogOutTile extends StatelessWidget {
  const _LogOutTile();

  @override
  Widget build(BuildContext context) {
    final danger = context.colors.danger;
    return ListTile(
      leading: Icon(Icons.logout_rounded, color: danger),
      title: Text(
        context.l10n.settingsLogOut,
        style: context.typography.bodyStrong.copyWith(color: danger),
      ),
      onTap: () =>
          context.read<SessionBloc>().add(const SessionSignOutRequested()),
    );
  }
}

class _LanguageOptions extends StatelessWidget {
  const _LanguageOptions();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = {
      'en': l10n.languageEnglish,
      'my': l10n.languageBurmese,
    };
    final selected =
        context.select<LocaleCubit, Locale?>(
          (cubit) => cubit.state,
        ) ??
        Localizations.localeOf(context);
    return RadioGroup<String>(
      groupValue: selected.languageCode,
      onChanged: (code) {
        if (code != null) context.read<LocaleCubit>().select(Locale(code));
      },
      child: Column(
        children: [
          for (final locale in AppLocalizations.supportedLocales)
            RadioListTile<String>(
              value: locale.languageCode,
              title: Text(
                labels[locale.languageCode] ?? locale.languageCode,
                style: context.typography.body,
              ),
            ),
        ],
      ),
    );
  }
}
