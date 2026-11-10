import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/config/routes/app_shell_scaffold.dart';
import 'package:jdonuts/core/theme/tokens/app_colors.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ShellNavigationBar', () {
    testWidgets('shows every destination label', (tester) async {
      await tester.pumpApp(
        Scaffold(
          bottomNavigationBar: ShellNavigationBar(
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Reward'), findsOneWidget);
      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('reports the tapped destination index', (tester) async {
      var selected = 0;
      await tester.pumpApp(
        StatefulBuilder(
          builder: (context, setState) => Scaffold(
            bottomNavigationBar: ShellNavigationBar(
              selectedIndex: selected,
              onSelected: (value) => setState(() => selected = value),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(ShellNavigationBar.destinationKey(2)));
      await tester.pumpAndSettle();

      expect(selected, 2);
      expect(find.text('Reward'), findsOneWidget);
    });

    testWidgets('uses surface bar and primary pill', (tester) async {
      await tester.pumpApp(
        Scaffold(
          bottomNavigationBar: ShellNavigationBar(
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      );

      const colors = AppColors.light;
      final decorations = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .toList();

      expect(
        decorations.any((decoration) => decoration.color == colors.surface),
        isTrue,
      );
      expect(
        decorations.any((decoration) => decoration.color == colors.primary),
        isTrue,
      );
    });
  });
}
