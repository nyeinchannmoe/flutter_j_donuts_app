import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/error/app_exception.dart';
import 'package:jdonuts/core/error/app_failure.dart';
import 'package:jdonuts/core/error/guard.dart';
import 'package:jdonuts/core/responsive/layout_metrics.dart';
import 'package:jdonuts/core/responsive/screen_class.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/utils/date_formatter.dart';
import 'package:jdonuts/core/utils/mmk_formatter.dart';

import '../helpers/device_matrix.dart';
import '../helpers/test_doubles.dart';

void main() {
  group('Result', () {
    const ok = Ok<int>(2);
    const err = Err<int>(NetworkFailure());

    test('exposes the value or the failure', () {
      expect(ok.valueOrNull, 2);
      expect(ok.failureOrNull, isNull);
      expect(err.valueOrNull, isNull);
      expect(err.failureOrNull, const NetworkFailure());
    });

    test('map and flatMap transform values and keep failures', () {
      expect(ok.map((value) => value * 2), const Ok(4));
      expect(err.map((value) => value * 2), const Err<int>(NetworkFailure()));
      expect(
        ok.flatMap<int>((_) => const Err(TimeoutFailure())),
        const Err<int>(TimeoutFailure()),
      );
    });

    test('fold picks the matching branch', () {
      expect(
        ok.fold(onOk: (value) => 'ok $value', onErr: (_) => 'err'),
        'ok 2',
      );
      expect(err.fold(onOk: (_) => 'ok', onErr: (f) => f.code), 'network');
    });
  });

  group('failure mapping', () {
    test('keeps the failure carried by an AppException', () {
      const failure = ValidationFailure();

      expect(
        mapErrorToFailure(const AppException(failure), StackTrace.empty),
        same(failure),
      );
    });

    test('maps timeouts and falls back for anything else', () {
      expect(
        mapErrorToFailure(TimeoutException('slow'), StackTrace.empty),
        isA<TimeoutFailure>(),
      );
      expect(
        mapErrorToFailure(StateError('boom'), StackTrace.empty),
        isA<UnexpectedFailure>(),
      );
    });

    test('guardResult turns a thrown error into a storage failure', () async {
      final result = await guardResult<int>(
        () => throw StateError('disk'),
        logger: silentLogger(),
      );

      expect(result.failureOrNull, isA<StorageFailure>());
    });

    test('guardStream keeps emitting after an error', () async {
      final source = StreamController<int>();
      final results = guardStream(
        source.stream,
        logger: silentLogger(),
      ).toList();

      source
        ..add(1)
        ..addError(StateError('read'))
        ..add(2);
      await source.close();

      expect(await results, [const Ok(1), isA<Err<int>>(), const Ok(2)]);
    });
  });

  group('LayoutMetrics', () {
    test('classifies the reference devices', () {
      ScreenClass classOf(Size size) =>
          LayoutMetrics.fromSize(size).screenClass;

      expect(classOf(DeviceMatrix.smallPhone), ScreenClass.compact);
      expect(classOf(DeviceMatrix.shortPhone), ScreenClass.compact);
      expect(classOf(DeviceMatrix.phone), ScreenClass.regular);
      expect(classOf(DeviceMatrix.largePhone), ScreenClass.expanded);
    });

    test('flags short screens and clamps the scale', () {
      final small = LayoutMetrics.fromSize(DeviceMatrix.smallPhone);
      final tablet = LayoutMetrics.fromSize(DeviceMatrix.tablet);

      expect(small.isShortHeight, isTrue);
      expect(small.scale, LayoutMetrics.minScale);
      expect(tablet.isShortHeight, isFalse);
      expect(tablet.scale, LayoutMetrics.maxScale);
    });
  });

  group('formatters', () {
    test('MmkFormatter groups thousands', () {
      expect(MmkFormatter.amount(3200), '3,200');
      expect(MmkFormatter.amount(1250000), '1,250,000');
    });

    test('DateFormatter writes long dates', () {
      expect(DateFormatter.longDate(DateTime(1980, 5), 'en_US'), 'May 1, 1980');
    });
  });
}
