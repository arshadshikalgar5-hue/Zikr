import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/app.dart';
import 'package:zikr/core/constants/app_routes.dart';
import 'package:zikr/core/router/app_router.dart';
import 'package:zikr/data/hive_boxes.dart';

import 'prayer_times_test_helpers.dart';

void main() {
  setUpPrayerTimesTests();

  testWidgets('picking a calculation method persists it to Hive', (
    tester,
  ) async {
    appRouter.go(AppRoutes.prayerSettings);
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(child: ZikrApp()));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Prayer Settings'), findsOneWidget);
    expect(
      Hive.box(HiveBoxes.prayerSettings).get('method'),
      isNull,
    ); // defaults to Muslim World League until changed

    await tester.tap(find.text('Umm al-Qura University, Makkah'));
    await tester.pumpAndSettle();

    expect(
      Hive.box(HiveBoxes.prayerSettings).get('method'),
      'umm_al_qura',
    );

    await tester.tap(find.text('Hanafi'));
    await tester.pumpAndSettle();

    expect(Hive.box(HiveBoxes.prayerSettings).get('madhab'), 'hanafi');
  });
}
