import 'package:flutter_test/flutter_test.dart';

import 'prayer_times_test_helpers.dart';

void main() {
  setUpPrayerTimesTests();

  testWidgets('with a cached location, shows today\'s prayer times', (
    tester,
  ) async {
    seedCairoLocation();
    await pumpApp(tester);

    expect(find.text('Cairo, Egypt'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Sunrise'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('Asr'), findsOneWidget);
    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);
  });
}
