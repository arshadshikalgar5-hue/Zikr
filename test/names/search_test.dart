import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'names_test_helpers.dart';

void main() {
  setUpNamesTests();

  testWidgets('searching across all names finds a match and opens it', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'self-subsisting sustainer');
    await tester.pumpAndSettle();

    expect(find.text('Al-Qayyum'), findsOneWidget);

    await tester.tap(find.text('Al-Qayyum'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Al-Qayyum'), findsOneWidget);
  });
}
