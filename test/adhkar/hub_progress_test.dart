import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'adhkar_test_helpers.dart';

void main() {
  setUpAdhkarTests();

  testWidgets('the hub shows 0 completed of the full count for each period', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('0 of 13 completed today'), findsOneWidget);
    expect(find.text('0 of 14 completed today'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Adhkar'), findsOneWidget);
  });
}
