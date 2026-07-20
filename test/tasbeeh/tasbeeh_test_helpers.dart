import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';
import 'package:zikr/features/tasbeeh/tasbeeh_screen.dart';

import '../support/hive_test_setup.dart';
import '../support/mock_platform_channels.dart';

final ring = find.byKey(const Key('tasbeehCounterRing'));

/// Registers the Hive + platform-channel setup shared by every Tasbeeh
/// test file. Each behavior lives in its own file (its own `flutter test`
/// process) rather than as multiple `testWidgets` in one file — sequential
/// tests that both write to Hive and open a dialog were observed to hang in
/// this sandbox's `flutter test` runner, and per-file isolation reliably
/// avoids it.
void setUpTasbeehTests() {
  setUpAll(() async {
    mockSystemChannels();
    await initTestHive();
  });
  tearDownAll(disposeTestHive);
  setUp(() {
    Hive.box(HiveBoxes.tasbeeh).clear();
    Hive.box(HiveBoxes.customDhikr).clear();
  });
}

/// The Tasbeeh screen's content is taller than the default 800x600 test
/// surface, which makes `tester.tap()` silently miss widgets below the fold.
/// Use a taller, phone-width surface so everything is laid out on screen.
Future<void> pumpTasbeeh(WidgetTester tester) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: TasbeehScreen())),
  );
}

/// A bounded `pumpAndSettle` — if something is genuinely still animating
/// (a real bug) this fails fast with a clear error instead of spinning for
/// the default 10-minute timeout.
Future<void> settle(WidgetTester tester) => tester.pumpAndSettle(
  const Duration(milliseconds: 100),
  EnginePhase.sendSemanticsUpdate,
  const Duration(seconds: 10),
);
