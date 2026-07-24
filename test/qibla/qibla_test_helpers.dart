import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/app.dart';
import 'package:zikr/core/constants/app_routes.dart';
import 'package:zikr/core/router/app_router.dart';
import 'package:zikr/data/hive_boxes.dart';

import '../support/hive_test_setup.dart';
import '../support/mock_platform_channels.dart';

/// Mirrors test/prayer_times/prayer_times_test_helpers.dart: one behavior
/// per file.
void setUpQiblaTests() {
  setUpAll(initTestHive);
  tearDownAll(disposeTestHive);
  setUp(() {
    mockCompassChannel();
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
/// `prayer_settings` Hive box — shared with Prayer Times, see
/// test/prayer_times/prayer_times_test_helpers.dart.
void seedCairoLocation() {
  Hive.box(HiveBoxes.prayerSettings).put('location', {
    'latitude': 30.0444,
    'longitude': 31.2357,
    'label': 'Cairo, Egypt',
    'isManual': true,
    'timezone': 'Africa/Cairo',
  });
}

/// Pumps the real app starting directly on the Qibla screen. [appRouter] is
/// a module-level singleton, so its location survives across tests in the
/// same file — reset it before each pump.
///
/// Deliberately bounded pumps, not `pumpAndSettle()`: once a location is
/// set, the compass shows a `CircularProgressIndicator` while it waits for
/// a heading reading that never arrives under `flutter test` (the compass
/// channel is mocked to answer with no further events) — an indeterminate
/// spinner's animation never settles, so `pumpAndSettle()` would time out.
Future<void> pumpApp(WidgetTester tester) async {
  appRouter.go(AppRoutes.qibla);

  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const ProviderScope(child: ZikrApp()));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}
