import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'tasbeeh_test_helpers.dart';

void main() {
  setUpTasbeehTests();

  testWidgets('selecting a goal preset updates the target', (tester) async {
    await pumpTasbeeh(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, '100'));
    await tester.pump();

    expect(find.text('of 100'), findsOneWidget);
    expect(Hive.box(HiveBoxes.tasbeeh).get('goal'), 100);
  });
}
