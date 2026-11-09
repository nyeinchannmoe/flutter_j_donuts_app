import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/motion/motion_policy.dart';
import 'package:jdonuts/core/motion/motion_profile.dart';
import 'package:jdonuts/core/motion/motion_scope.dart';
import 'package:jdonuts/core/theme/app_theme.dart';
import 'package:jdonuts/core/widgets/skeleton/skeleton_scope.dart';
import 'package:jdonuts/l10n/generated/app_localizations.dart';

import 'device_matrix.dart';

extension PumpApp on WidgetTester {
  /// Pumps [child] inside the app theme, localizations, motion scope and
  /// the optional [providers].
  ///
  /// [tier] minimal is reached the same way users reach it: through the
  /// platform reduce-motion setting.
  Future<void> pumpApp(
    Widget child, {
    List<BlocProvider<StateStreamableSource<Object?>>> providers = const [],
    MotionTier tier = MotionTier.full,
    Size size = DeviceMatrix.phone,
    double textScale = 1,
    Locale locale = const Locale('en'),
  }) async {
    await binding.setSurfaceSize(size);
    addTearDown(() => binding.setSurfaceSize(null));
    final policy = MotionPolicy();
    addTearDown(policy.dispose);
    if (tier == MotionTier.reduced) policy.downgradeForJank();
    final body = providers.isEmpty
        ? child
        : MultiBlocProvider(providers: providers, child: child);
    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: tier == MotionTier.minimal,
            textScaler: TextScaler.linear(textScale),
          ),
          child: MotionScope(
            policy: policy,
            child: SkeletonScope(child: app!),
          ),
        ),
        home: body,
      ),
    );
  }

  /// Pumps for the current DeviceMatrix.variant case.
  Future<void> pumpOnDevice(
    Widget child, {
    List<BlocProvider<StateStreamableSource<Object?>>> providers = const [],
  }) {
    final device = DeviceMatrix.variant.currentValue!;
    return pumpApp(
      child,
      providers: providers,
      size: device.size,
      textScale: device.textScale,
    );
  }
}
