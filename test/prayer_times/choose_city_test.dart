import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'prayer_times_test_helpers.dart';

void main() {
  setUpPrayerTimesTests();

  testWidgets('choosing a city manually sets the location and shows times', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Choose a City'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Jakarta');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Jakarta'), findsOneWidget);
    expect(find.text('Indonesia'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Jakarta'));
    await tester.pumpAndSettle();

    expect(find.text('Jakarta, Indonesia'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
  });
}
