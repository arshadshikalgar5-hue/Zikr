import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';
import 'package:zikr/data/namaz_tracker_repository.dart';

import 'namaz_tracker_test_helpers.dart';

void main() {
  setUpNamazTrackerTests();

  testWidgets('marking a prayer complete persists to Hive', (tester) async {
    await pumpApp(tester);

    expect(find.text('Fajr'), findsOneWidget);

    await tester.tap(find.text('Fajr'));
    await tester.pump();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    final key = namazTrackerKey(DateTime.now());
    final stored = Hive.box(HiveBoxes.namazTracker).get(key) as List<dynamic>?;
    expect(stored, contains('Fajr'));
  });
}
