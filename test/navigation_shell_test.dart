import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zikr/app.dart';

import 'support/hive_test_setup.dart';

void main() {
  // The Tasbeeh tab reads from Hive, so it needs to be initialized even
  // though this test isn't exercising the counter itself.
  setUpAll(initTestHive);
  tearDownAll(disposeTestHive);

  testWidgets('bottom nav switches tabs and More pushes a sub-screen', (
    tester,
  ) async {
    // The More list now has 9 rows; give the surface enough height that
    // every row (including "Settings") is laid out and tappable without
    // needing to scroll the list first.
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: ZikrApp()));
    await tester.pumpAndSettle();

    expect(find.text('Tasbeeh Counter'), findsOneWidget); // Home dashboard

    await tester.tap(find.text('Tasbeeh'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Tasbeeh'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'More'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);

    // Back button pops to More, not out of the app.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'More'), findsOneWidget);
  });
}
