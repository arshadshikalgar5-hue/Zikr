import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'prayer_times_test_helpers.dart';

void main() {
  setUpPrayerTimesTests();

  testWidgets('with no cached location, shows the location picker prompt', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.widgetWithText(AppBar, 'Prayer Times'), findsOneWidget);
    expect(find.text("Find today's prayer times"), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Use My Location'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Choose a City'), findsOneWidget);
    expect(find.text('Fajr'), findsNothing);
  });
}
