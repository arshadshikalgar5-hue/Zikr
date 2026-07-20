import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'duas_test_helpers.dart';

void main() {
  setUpDuasTests();

  testWidgets('a query with no matches shows an empty state', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzznomatch');
    await tester.pumpAndSettle();

    expect(find.text('No duas found.'), findsOneWidget);
  });
}
