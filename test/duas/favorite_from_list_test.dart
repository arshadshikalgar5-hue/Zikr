import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'duas_test_helpers.dart';

void main() {
  setUpDuasTests();

  testWidgets('favoriting from the category list persists to Hive', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Sleep'));
    await tester.pumpAndSettle();

    final favoriteButton = find.byIcon(Icons.favorite_border);
    expect(favoriteButton, findsOneWidget);

    await tester.tap(favoriteButton);
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(Hive.box(HiveBoxes.favoriteDuas).containsKey('sleep-1'), isTrue);
  });
}
