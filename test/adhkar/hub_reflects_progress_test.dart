import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'adhkar_test_helpers.dart';

void main() {
  setUpAdhkarTests();

  testWidgets('completing an item in Evening updates the hub count', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Evening Adhkar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('1 of 14 completed today'), findsOneWidget);
    expect(find.text('0 of 13 completed today'), findsOneWidget);
  });
}
