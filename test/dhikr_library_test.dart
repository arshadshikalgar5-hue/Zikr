import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zikr/app.dart';

import 'support/hive_test_setup.dart';

void main() {
  setUpAll(initTestHive);
  tearDownAll(disposeTestHive);

  testWidgets(
    'Dhikr Library lists entries and shows full details on tap',
    (tester) async {
      // The library list (11 rows) needs more height than the default
      // test surface to lay out without scrolling.
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const ProviderScope(child: ZikrApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dhikr Library'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Dhikr Library'), findsOneWidget);

      expect(find.text('Subhan Allah'), findsOneWidget);
      expect(find.text('Hasbunallahu wa ni\'mal wakeel'), findsOneWidget);

      await tester.tap(find.text('Subhan Allah'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Subhan Allah'), findsOneWidget);
      expect(find.text('سُبْحَانَ اللَّهِ'), findsOneWidget);
      expect(find.text('Glory be to Allah'), findsOneWidget);
      expect(find.text('Sahih Muslim 596'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Dhikr Library'), findsOneWidget);
    },
  );
}
