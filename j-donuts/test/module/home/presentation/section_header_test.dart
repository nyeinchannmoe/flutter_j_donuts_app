import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/module/home/presentation/screens/home/widgets/section_header.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('invokes onSeeAll when the see-all control is tapped', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpApp(
      Scaffold(
        body: SectionHeader(title: 'Popular', onSeeAll: () => taps++),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
    await tester.pump();

    expect(taps, 1);
    expect(find.text('Popular'), findsOneWidget);
  });
}
