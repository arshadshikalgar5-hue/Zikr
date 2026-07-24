import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'qibla_test_helpers.dart';

void main() {
  setUpQiblaTests();

  testWidgets('choosing a city manually sets the location and shows the bearing', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Choose a City'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Jakarta');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Jakarta'));
    // Not pumpAndSettle(): once a location is set, the compass shows a
    // perpetual CircularProgressIndicator waiting for a heading reading
    // that never arrives under `flutter test` — see qibla_test_helpers.dart.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Jakarta, Indonesia'), findsOneWidget);
    expect(find.textContaining('° from North'), findsOneWidget);
  });
}
