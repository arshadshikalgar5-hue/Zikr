import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'tasbeeh_test_helpers.dart';

void main() {
  setUpTasbeehTests();

  testWidgets('sound and vibration toggles persist', (tester) async {
    await pumpTasbeeh(tester);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Sound'));
    await tester.tap(find.widgetWithText(SwitchListTile, 'Vibration'));
    await tester.pump();

    expect(Hive.box(HiveBoxes.tasbeeh).get('soundEnabled'), false);
    expect(Hive.box(HiveBoxes.tasbeeh).get('vibrationEnabled'), false);
  });
}
