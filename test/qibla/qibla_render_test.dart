import 'package:flutter_test/flutter_test.dart';

import 'qibla_test_helpers.dart';

void main() {
  setUpQiblaTests();

  testWidgets('with a cached location, shows the qibla bearing and distance', (
    tester,
  ) async {
    seedCairoLocation();
    await pumpApp(tester);

    expect(find.text('Cairo, Egypt'), findsOneWidget);
    expect(find.textContaining('° from North'), findsOneWidget);
    expect(find.textContaining('km to the Kaaba'), findsOneWidget);
  });
}
