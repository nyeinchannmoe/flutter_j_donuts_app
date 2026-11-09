import 'package:intl/intl.dart';

/// Locale-aware date formatting for display.
abstract final class DateFormatter {
  /// Long month, day and year in [localeName], for example "May 1, 1980".
  static String longDate(DateTime date, String localeName) =>
      DateFormat.yMMMMd(localeName).format(date);
}
