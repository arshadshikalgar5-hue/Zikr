import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hadith_test_helpers.dart';

void main() {
  setUpHadithTests();

  testWidgets('tapping a category shows its hadith', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Intentions'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Intentions'), findsOneWidget);
    expect(
      find.textContaining('Actions are judged by intentions'),
      findsOneWidget,
    );

    await tester.tap(find.textContaining('Actions are judged by intentions'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Intentions'), findsOneWidget);
    expect(find.text('Sahih al-Bukhari, Hadith 1'), findsOneWidget);
  });
}
