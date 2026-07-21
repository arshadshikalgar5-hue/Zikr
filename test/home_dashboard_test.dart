import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zikr/app.dart';
import 'package:zikr/core/constants/app_routes.dart';
import 'package:zikr/core/router/app_router.dart';

import 'support/hive_test_setup.dart';

/// The dashboard grid has 6 rows; give the test surface enough height that
/// GridView.builder lays out every row without needing a scroll.
///
/// [appRouter] is a module-level singleton, so its location survives across
/// tests in this file — reset it to Home before each pump.
Future<void> _pumpTallApp(WidgetTester tester) async {
  appRouter.go(AppRoutes.home);

  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const ProviderScope(child: ZikrApp()));
  await tester.pumpAndSettle();
}

void main() {
  // The Prayer Times tab reads from Hive, so it needs to be initialized
  // even though most of these tests don't exercise that screen.
  setUpAll(initTestHive);
  tearDownAll(disposeTestHive);

  testWidgets('dashboard renders all 11 cards', (tester) async {
    await _pumpTallApp(tester);

    const labels = [
      'Tasbeeh Counter',
      'Duas',
      'Morning & Evening Adhkar',
      'Namaz Tracker',
      'Prayer Times',
      'Qibla',
      'Hadith',
      '99 Names of Allah',
      'Favorites',
      'Progress',
      'Settings',
    ];
    final grid = find.byType(GridView);
    for (final label in labels) {
      expect(
        find.descendant(of: grid, matching: find.text(label)),
        findsOneWidget,
        reason: '$label card missing',
      );
    }
  });

  testWidgets('a tab card (Prayer Times) switches the bottom nav tab', (
    tester,
  ) async {
    await _pumpTallApp(tester);

    await tester.tap(find.text('Prayer Times'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Prayer Times'), findsOneWidget);
    // Still inside the shell: the bottom nav bar is present and back does
    // not pop the whole screen away.
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('a push card (Settings) opens a full-screen route with back', (
    tester,
  ) async {
    await _pumpTallApp(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Tasbeeh Counter'), findsOneWidget); // back on Home
  });
}
