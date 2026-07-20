import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/custom_dhikr_repository.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'custom_dhikr_test_helpers.dart';

void main() {
  setUpCustomDhikrTests();

  testWidgets('editing a custom dhikr updates the list and Hive', (
    tester,
  ) async {
    // Not awaited: Box.put()'s in-memory update is synchronous, and
    // awaiting its disk-flush Future here never resolves inside a
    // testWidgets body's FakeAsync zone.
    Hive.box(HiveBoxes.customDhikr).put(1, {
      'text': 'Original text',
      'transliteration': null,
      'meaning': null,
    });

    await pumpApp(tester);
    await goToCustomDhikr(tester);

    expect(find.text('Original text'), findsOneWidget);

    await tester.tap(find.text('Original text'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Edit Dhikr'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Dhikr text'),
      'Updated text',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('Updated text'), findsOneWidget);
    expect(find.text('Original text'), findsNothing);

    final stored = Hive.box(HiveBoxes.customDhikr).get(1) as Map;
    expect(CustomDhikrEntry.fromMap(1, stored).text, 'Updated text');
  });
}
