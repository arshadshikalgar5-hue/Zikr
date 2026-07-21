import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'names_test_helpers.dart';

void main() {
  setUpNamesTests();

  testWidgets('the first name renders and opens its detail screen', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.widgetWithText(AppBar, '99 Names of Allah'), findsOneWidget);
    expect(find.text('Ar-Rahman — The Most Compassionate'), findsOneWidget);

    await tester.tap(find.text('Ar-Rahman — The Most Compassionate'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Ar-Rahman'), findsOneWidget);
    expect(find.text('الرَّحْمَٰن'), findsOneWidget);
    expect(
      find.textContaining('mercy encompasses all of creation'),
      findsOneWidget,
    );
  });
}
