import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'duas_test_helpers.dart';

void main() {
  setUpDuasTests();

  testWidgets('favoriting from the detail screen toggles back off', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Rain'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allahumma sayyiban nafi\'an'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();
    expect(Hive.box(HiveBoxes.favoriteDuas).containsKey('rain-1'), isTrue);

    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pump();
    expect(Hive.box(HiveBoxes.favoriteDuas).containsKey('rain-1'), isFalse);
  });
}
