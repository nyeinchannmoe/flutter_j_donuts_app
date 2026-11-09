import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:jdonuts/core/locale/locale_preference_store.dart';

/// App language. A null state follows the device locale.
///
/// The stored choice is read in bootstrap and passed in, so the first
/// frame already uses the right language.
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit({required this._store, Locale? initial}) : super(initial);

  final LocalePreferenceStore _store;

  void select(Locale locale) {
    if (state == locale) return;
    emit(locale);
    unawaited(_store.write(locale.languageCode));
  }
}
