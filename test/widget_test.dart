import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zikr/app.dart';

void main() {
  testWidgets('App boots to the Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ZikrApp()));
    await tester.pumpAndSettle();

    expect(find.text('Zikr'), findsWidgets);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
}
