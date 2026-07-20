import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tasbeeh_test_helpers.dart';

void main() {
  setUpTasbeehTests();

  testWidgets('Reset asks for confirmation before zeroing the count', (
    tester,
  ) async {
    await pumpTasbeeh(tester);

    await tester.tap(ring);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
    await settle(tester);

    // Cancel leaves the count untouched.
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await settle(tester);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await settle(tester);
    expect(find.text('0'), findsOneWidget);
  });
}
