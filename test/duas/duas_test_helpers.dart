import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/app.dart';
import 'package:zikr/core/constants/app_routes.dart';
import 'package:zikr/core/router/app_router.dart';
import 'package:zikr/data/hive_boxes.dart';

import '../support/hive_test_setup.dart';

/// Mirrors test/custom_dhikr/custom_dhikr_test_helpers.dart: one behavior
/// per file (its own `flutter test` process) for reliable isolation.
void setUpDuasTests() {
  setUpAll(initTestHive);
  tearDownAll(disposeTestHive);
  setUp(() {
    Hive.box(HiveBoxes.tasbeeh).clear();
    Hive.box(HiveBoxes.customDhikr).clear();
    Hive.box(HiveBoxes.favoriteDuas).clear();
  });
}

/// Pumps the real app starting directly on the Duas tab. [appRouter] is a
/// module-level singleton, so its location survives across tests in the
/// same file — going straight to the Duas route also sidesteps having to
/// tap the "Duas" label, which is ambiguous on Home (it's both a bottom-nav
/// label and a dashboard card).
Future<void> pumpApp(WidgetTester tester) async {
  appRouter.go(AppRoutes.duas);

  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const ProviderScope(child: ZikrApp()));
  await tester.pumpAndSettle();
}
