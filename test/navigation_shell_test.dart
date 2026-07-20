import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zikr/app.dart';

void main() {
  testWidgets('bottom nav switches tabs and More pushes a sub-screen', (
    tester,
  ) async {
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
