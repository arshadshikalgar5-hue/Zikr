import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';
import 'package:zikr/data/namaz_tracker_repository.dart';

import 'namaz_tracker_test_helpers.dart';

void main() {
  setUpNamazTrackerTests();

  testWidgets('a fully-completed yesterday shows a 1 day streak', (
    tester,
  ) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    Hive.box(
      HiveBoxes.namazTracker,
    ).put(namazTrackerKey(yesterday), namazPrayers);

    await pumpApp(tester);

    expect(find.text('1 day streak of all 5 prayers'), findsOneWidget);
  });
}
