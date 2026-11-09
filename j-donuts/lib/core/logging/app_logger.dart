import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Single logging entry point. Release builds keep warnings and errors only.
class AppLogger {
  AppLogger({Logger? logger})
    : _logger =
          logger ??
          Logger(
            level: kReleaseMode ? Level.warning : Level.debug,
            printer: PrettyPrinter(methodCount: 0),
          );

  final Logger _logger;

  void debug(String message) => _logger.d(message);

  void info(String message) => _logger.i(message);

  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
