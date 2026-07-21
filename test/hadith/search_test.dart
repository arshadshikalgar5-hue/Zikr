import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hadith_test_helpers.dart';

void main() {
  setUpHadithTests();

  testWidgets('searching across all hadith finds a match and opens it', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'charity does not decrease');
    await tester.pumpAndSettle();

    expect(find.textContaining('Charity does not decrease'), findsOneWidget);
    expect(find.textContaining('Charity · Sahih Muslim'), findsOneWidget);

    await tester.tap(find.textContaining('Charity does not decrease'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Charity'), findsOneWidget);
  });
}
