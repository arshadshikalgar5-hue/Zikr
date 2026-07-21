import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'names_test_helpers.dart';

void main() {
  setUpNamesTests();

  testWidgets('favoriting from the list persists to Hive', (tester) async {
    await pumpApp(tester);

    final favoriteButton = find.byIcon(Icons.favorite_border).first;
    await tester.tap(favoriteButton);
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(
      Hive.box(HiveBoxes.favoriteNames).containsKey('01-ar-rahman'),
      isTrue,
    );
  });
}
