import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'namaz_tracker_test_helpers.dart';

void main() {
  setUpNamazTrackerTests();

  testWidgets('switching to the Weekly and Monthly tabs renders their content', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
  });
}
