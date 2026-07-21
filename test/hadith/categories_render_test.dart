import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hadith_test_helpers.dart';

void main() {
  setUpHadithTests();

  testWidgets('all 10 categories render, in JSON order', (tester) async {
    await pumpApp(tester);

    const expectedOrder = [
      'Faith',
      'Prayer',
      'Charity',
      'Fasting',
      'Good Character',
      'Knowledge',
      'Mercy & Kindness',
      'Intentions',
      'Patience',
      'Parents & Family',
    ];

    final titles = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(ListTile),
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data)
        .whereType<String>()
        .where(expectedOrder.contains)
        .toList();

    expect(titles, expectedOrder);
  });
}
