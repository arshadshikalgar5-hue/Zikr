import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/app.dart';
import 'package:zikr/core/constants/app_routes.dart';
import 'package:zikr/core/router/app_router.dart';
import 'package:zikr/data/hive_boxes.dart';

import '../support/hive_test_setup.dart';

/// Mirrors test/tasbeeh/tasbeeh_test_helpers.dart: one behavior per file
/// (its own `flutter test` process) for reliable isolation in this sandbox.
void setUpCustomDhikrTests() {
  setUpAll(initTestHive);
  tearDownAll(disposeTestHive);
  setUp(() {
    Hive.box(HiveBoxes.tasbeeh).clear();
    Hive.box(HiveBoxes.customDhikr).clear();
  });
}

/// Custom Dhikr screens navigate via go_router, so tests need the real app
/// (not an isolated MaterialApp) plus a taller surface for the form fields.
///
/// [appRouter] is a module-level singleton, so its location survives across
/// tests in the same file — reset it to Home before each pump.
Future<void> pumpApp(WidgetTester tester) async {
  appRouter.go(AppRoutes.home);

  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const ProviderScope(child: ZikrApp()));
  await tester.pumpAndSettle();
}

Future<void> goToCustomDhikr(WidgetTester tester) async {
  await tester.tap(find.text('More'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Custom Dhikr'));
  await tester.pumpAndSettle();
}
