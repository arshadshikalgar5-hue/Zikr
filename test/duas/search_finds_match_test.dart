import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'duas_test_helpers.dart';

void main() {
  setUpDuasTests();

  testWidgets('searching across all duas finds a match and opens it', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'beneficial rain');
    await tester.pumpAndSettle();

    expect(find.text('Allahumma sayyiban nafi\'an'), findsOneWidget);
    expect(find.textContaining('Rain ·'), findsOneWidget);

    await tester.tap(find.text('Allahumma sayyiban nafi\'an'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Rain'), findsOneWidget);
  });
}
