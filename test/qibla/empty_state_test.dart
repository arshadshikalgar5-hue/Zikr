import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'qibla_test_helpers.dart';

void main() {
  setUpQiblaTests();

  testWidgets('with no cached location, shows the location picker prompt', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.widgetWithText(AppBar, 'Qibla'), findsOneWidget);
    expect(find.text('Find the Qibla direction'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Use My Location'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Choose a City'), findsOneWidget);
  });
}
