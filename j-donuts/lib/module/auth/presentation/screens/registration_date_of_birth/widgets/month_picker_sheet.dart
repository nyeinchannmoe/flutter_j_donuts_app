import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jdonuts/core/extensions/build_context_x.dart';
import 'package:jdonuts/module/auth/domain/validators/date_of_birth_validator.dart';

/// Fraction of the screen height used by the month list sheet.
const double _monthSheetHeightFactor = 0.65;

// quality-gate: allow function-length - sheet chrome and list stay together
/// Opens a themed month list and returns the chosen month (1-12), or null.
Future<int?> showMonthPickerSheet({
  required BuildContext context,
  required int? selectedMonth,
  required String title,
}) {
  final colors = context.colors;
  final spacing = context.spacing;
  final locale = context.l10n.localeName;
  final sheetHeight =
      MediaQuery.sizeOf(context).height * _monthSheetHeightFactor;
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: colors.surface,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(context.radius.lg),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      child: SizedBox(
        height: sheetHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.xl,
                spacing.lg,
                spacing.xl,
                spacing.sm,
              ),
              child: Text(title, style: context.typography.title),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: DateOfBirthValidator.maxMonth,
                itemBuilder: (context, index) {
                  final month = index + DateOfBirthValidator.minMonth;
                  return _MonthTile(
                    month: month,
                    label: monthLabel(month, locale),
                    selected: month == selectedMonth,
                    onTap: () => Navigator.pop(sheetContext, month),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String monthLabel(int month, String locale) =>
    DateFormat.MMMM(locale).format(DateTime(2000, month));

class _MonthTile extends StatelessWidget {
  const _MonthTile({
    required this.month,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final int month;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = selected
        ? context.typography.bodyStrong
        : context.typography.body;
    return ListTile(
      title: Text(label, style: style.copyWith(color: colors.textPrimary)),
      selected: selected,
      selectedTileColor: colors.surfaceMuted,
      onTap: onTap,
    );
  }
}
