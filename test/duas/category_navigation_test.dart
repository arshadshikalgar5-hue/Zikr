import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'duas_test_helpers.dart';

void main() {
  setUpDuasTests();

  testWidgets('tapping a category shows its dua', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Istikhara'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Istikhara'), findsOneWidget);
    expect(
      find.text(
        'Allahumma inni astakhiruka bi\'ilmika, wa astaqdiruka biqudratika, '
        'wa as\'aluka min fadlika-l-\'azim, fa innaka taqdiru wa la aqdir, '
        'wa ta\'lamu wa la a\'lam, wa anta \'allamu-l-ghuyub',
      ),
      findsOneWidget,
    );
  });
}
