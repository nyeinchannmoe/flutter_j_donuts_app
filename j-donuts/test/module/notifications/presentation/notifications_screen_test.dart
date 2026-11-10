import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/module/notifications/presentation/screens/notifications/notifications_screen.dart';

import '../../../helpers/device_matrix.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'renders the notifications title without overflowing',
    (tester) async {
      await tester.pumpOnDevice(const NotificationsScreen());

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    },
    variant: DeviceMatrix.variant,
  );
}
