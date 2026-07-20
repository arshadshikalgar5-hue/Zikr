import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'duas_test_helpers.dart';

void main() {
  setUpDuasTests();

  testWidgets('all 12 categories render, in JSON order', (tester) async {
    await pumpApp(tester);

    const expectedOrder = [
      'Sleep',
      'Wake Up',
      'Travel',
      'Eating',
      'Home',
      'Mosque',
      'Rain',
      'Parents',
      'Forgiveness',
      'Sickness',
      'Marriage',
      'Istikhara',
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
