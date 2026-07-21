import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:zikr/app.dart';
import 'package:zikr/core/constants/app_routes.dart';
import 'package:zikr/core/router/app_router.dart';
import 'package:zikr/data/hive_boxes.dart';

import '../support/hive_test_setup.dart';

/// Mirrors test/names/names_test_helpers.dart: one behavior per file.
void setUpPrayerTimesTests() {
  setUpAll(() {
    tz.initializeTimeZones();
    return initTestHive();
  });
  tearDownAll(disposeTestHive);
  setUp(() {
    Hive.box(HiveBoxes.tasbeeh).clear();
    Hive.box(HiveBoxes.customDhikr).clear();
    Hive.box(HiveBoxes.favoriteDuas).clear();
    Hive.box(HiveBoxes.adhkarProgress).clear();
    Hive.box(HiveBoxes.favoriteHadith).clear();
    Hive.box(HiveBoxes.favoriteNames).clear();
    Hive.box(HiveBoxes.namazTracker).clear();
    Hive.box(HiveBoxes.prayerSettings).clear();
  });
}

/// Seeds a manual (non-GPS) cached location directly into the
/// `prayer_settings` Hive box, so a test can render prayer times without
/// exercising the real (platform-channel-backed) device location lookup.
void seedCairoLocation() {
  Hive.box(HiveBoxes.prayerSettings).put('location', {
    'latitude': 30.0444,
    'longitude': 31.2357,
    'label': 'Cairo, Egypt',
    'isManual': true,
    'timezone': 'Africa/Cairo',
  });
}

/// Pumps the real app starting directly on the Prayer Times screen.
/// [appRouter] is a module-level singleton, so its location survives across
/// tests in the same file — reset it before each pump.
Future<void> pumpApp(WidgetTester tester) async {
  appRouter.go(AppRoutes.prayerTimes);

  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const ProviderScope(child: ZikrApp()));
  await tester.pumpAndSettle();
}
