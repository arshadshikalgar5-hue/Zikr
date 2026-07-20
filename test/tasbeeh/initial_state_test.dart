import 'package:flutter_test/flutter_test.dart';

import 'tasbeeh_test_helpers.dart';

void main() {
  setUpTasbeehTests();

  testWidgets('starts at 0 of the default 33 goal with Subhan Allah', (
    tester,
  ) async {
    await pumpTasbeeh(tester);
    await settle(tester); // dhikr dropdown loads its presets asynchronously

    expect(find.text('0'), findsOneWidget);
    expect(find.text('of 33'), findsOneWidget);
    expect(find.text('Subhan Allah'), findsWidgets);
  });
}
