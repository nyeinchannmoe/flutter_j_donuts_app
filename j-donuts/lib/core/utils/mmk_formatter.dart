import 'package:intl/intl.dart';

/// Formats Myanmar kyat amounts with thousands separators.
///
/// Digits use Latin numerals in every locale so prices match receipts.
abstract final class MmkFormatter {
  static final NumberFormat _grouping = NumberFormat.decimalPattern('en_US');

  /// 3200 becomes "3,200".
  static String amount(int value) => _grouping.format(value);
}
