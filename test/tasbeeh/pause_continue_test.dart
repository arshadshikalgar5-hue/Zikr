import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tasbeeh_test_helpers.dart';

void main() {
  setUpTasbeehTests();

  testWidgets('Pause stops increments; Continue resumes them', (
    tester,
  ) async {
    await pumpTasbeeh(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Pause'));
    await tester.pump();
    expect(find.text('Paused'), findsOneWidget);

    await tester.tap(ring);
    await tester.pump();
    expect(find.text('0'), findsOneWidget); // tap while paused did nothing

    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pump();
    await tester.tap(ring);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
