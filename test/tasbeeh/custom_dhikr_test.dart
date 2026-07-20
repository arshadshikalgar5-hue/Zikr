import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'tasbeeh_test_helpers.dart';

void main() {
  setUpTasbeehTests();

  testWidgets('switching to a custom dhikr updates the reciting label', (
    tester,
  ) async {
    await pumpTasbeeh(tester);
    await settle(tester); // dhikr dropdown loads its presets asynchronously

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await settle(tester);
    await tester.tap(find.text('Custom...').last);
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'Ya Rahman');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Ya Rahman'), findsWidgets);
    expect(Hive.box(HiveBoxes.tasbeeh).get('dhikr'), 'Ya Rahman');
  });
}
