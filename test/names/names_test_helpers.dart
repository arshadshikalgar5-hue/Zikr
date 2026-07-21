import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/app.dart';
import 'package:zikr/core/constants/app_routes.dart';
import 'package:zikr/core/router/app_router.dart';
import 'package:zikr/data/hive_boxes.dart';

import '../support/hive_test_setup.dart';

/// Mirrors test/hadith/hadith_test_helpers.dart: one behavior per file.
void setUpNamesTests() {
  setUpAll(initTestHive);
  tearDownAll(disposeTestHive);
  setUp(() {
    Hive.box(HiveBoxes.tasbeeh).clear();
    Hive.box(HiveBoxes.customDhikr).clear();
    Hive.box(HiveBoxes.favoriteDuas).clear();
    Hive.box(HiveBoxes.adhkarProgress).clear();
    Hive.box(HiveBoxes.favoriteHadith).clear();
    Hive.box(HiveBoxes.favoriteNames).clear();
  });
}

/// Pumps the real app starting directly on the Names screen. [appRouter]
/// is a module-level singleton, so its location survives across tests in
/// the same file — reset it before each pump.
Future<void> pumpApp(WidgetTester tester) async {
  appRouter.go(AppRoutes.names);

  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const ProviderScope(child: ZikrApp()));
  await tester.pumpAndSettle();
}
