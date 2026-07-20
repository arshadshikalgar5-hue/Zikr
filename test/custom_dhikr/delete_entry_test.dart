import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'custom_dhikr_test_helpers.dart';

void main() {
  setUpCustomDhikrTests();

  testWidgets('swiping a custom dhikr away deletes it after confirmation', (
    tester,
  ) async {
    // Not awaited: Box.put()'s in-memory update is synchronous, and
    // awaiting its disk-flush Future here never resolves inside a
    // testWidgets body's FakeAsync zone.
    Hive.box(HiveBoxes.customDhikr).put(1, {
      'text': 'Delete me',
      'transliteration': null,
      'meaning': null,
    });

    await pumpApp(tester);
    await goToCustomDhikr(tester);

    expect(find.text('Delete me'), findsOneWidget);

    await tester.drag(find.text('Delete me'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Confirmation dialog blocks the dismiss until answered.
    expect(find.text('Delete this dhikr?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete me'), findsNothing);
    expect(Hive.box(HiveBoxes.customDhikr).isEmpty, isTrue);
  });
}
