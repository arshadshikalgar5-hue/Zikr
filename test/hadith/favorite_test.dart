import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'hadith_test_helpers.dart';

void main() {
  setUpHadithTests();

  testWidgets('favoriting from the category list persists to Hive', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Faith'));
    await tester.pumpAndSettle();

    final favoriteButton = find.byIcon(Icons.favorite_border);
    expect(favoriteButton, findsOneWidget);

    await tester.tap(favoriteButton);
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(Hive.box(HiveBoxes.favoriteHadith).containsKey('faith-1'), isTrue);
  });
}
