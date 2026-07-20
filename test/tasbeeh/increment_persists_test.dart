import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'tasbeeh_test_helpers.dart';

void main() {
  setUpTasbeehTests();

  testWidgets('tapping the ring increments and persists the count', (
    tester,
  ) async {
    await pumpTasbeeh(tester);

    await tester.tap(ring);
    await tester.tap(ring);
    await tester.tap(ring);
    await tester.pump();

    expect(find.text('3'), findsOneWidget);
    expect(Hive.box(HiveBoxes.tasbeeh).get('count'), 3);

    // Simulate an app relaunch: a fresh widget tree re-reads the box.
    await pumpTasbeeh(tester);
    expect(find.text('3'), findsOneWidget);
  });
}
