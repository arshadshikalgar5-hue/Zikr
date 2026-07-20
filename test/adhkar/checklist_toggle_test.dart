import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/adhkar_progress_repository.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'adhkar_test_helpers.dart';

void main() {
  setUpAdhkarTests();

  testWidgets('checking an item persists it under today\'s Hive key', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Morning Adhkar'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Morning Adhkar'), findsOneWidget);

    final firstCheckbox = find.byType(Checkbox).first;
    Checkbox checkboxWidget() => tester.widget<Checkbox>(firstCheckbox);
    expect(checkboxWidget().value, isFalse);

    await tester.tap(firstCheckbox);
    await tester.pump();

    expect(checkboxWidget().value, isTrue);

    final today = adhkarProgressKey('morning', DateTime.now());
    final stored = Hive.box(HiveBoxes.adhkarProgress).get(today) as List?;
    expect(stored, isNotNull);
    expect(stored, hasLength(1));
  });
}
