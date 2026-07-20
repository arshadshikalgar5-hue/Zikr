import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'custom_dhikr_test_helpers.dart';

void main() {
  setUpCustomDhikrTests();

  testWidgets('adding a custom dhikr shows it in the list', (tester) async {
    await pumpApp(tester);
    await goToCustomDhikr(tester);

    expect(find.text('No custom dhikr yet. Tap + to add your own.'),
        findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Add Dhikr'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Dhikr text'),
      'Ya Rahman Ya Raheem',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Meaning (optional)'),
      'O Most Merciful, O Most Compassionate',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Custom Dhikr'), findsOneWidget);
    expect(find.text('Ya Rahman Ya Raheem'), findsOneWidget);
    expect(find.text('O Most Merciful, O Most Compassionate'), findsOneWidget);
  });

  testWidgets('empty dhikr text is rejected', (tester) async {
    await pumpApp(tester);
    await goToCustomDhikr(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    // Still on the form — validation blocked the save.
    expect(find.widgetWithText(AppBar, 'Add Dhikr'), findsOneWidget);
    expect(find.text('Enter the dhikr text'), findsOneWidget);
  });
}
