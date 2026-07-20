import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'custom_dhikr_test_helpers.dart';

void main() {
  setUpCustomDhikrTests();

  testWidgets('a saved custom dhikr appears in the Tasbeeh dropdown', (
    tester,
  ) async {
    await pumpApp(tester);
    await goToCustomDhikr(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Dhikr text'),
      'Ya Wadud',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    // Back out of the pushed Custom Dhikr screens to the shell (which has
    // the bottom nav bar) before switching tabs.
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tasbeeh'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    expect(find.text('Ya Wadud'), findsWidgets);
  });
}
