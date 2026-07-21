import 'dart:io';

import 'package:hive/hive.dart';
import 'package:zikr/data/hive_boxes.dart';

Directory? _tempDir;

/// Real (non-Flutter) Hive init pointed at a temp directory — avoids
/// `Hive.initFlutter()`'s path_provider platform channel, which isn't
/// available under plain `flutter test`.
Future<void> initTestHive() async {
  _tempDir = await Directory.systemTemp.createTemp('zikr_hive_test_');
  Hive.init(_tempDir!.path);
  await Hive.openBox(HiveBoxes.tasbeeh);
  await Hive.openBox(HiveBoxes.customDhikr);
  await Hive.openBox(HiveBoxes.favoriteDuas);
  await Hive.openBox(HiveBoxes.adhkarProgress);
  await Hive.openBox(HiveBoxes.favoriteHadith);
  await Hive.openBox(HiveBoxes.favoriteNames);
  await Hive.openBox(HiveBoxes.namazTracker);
}


/// Deliberately doesn't call `box.close()` / `Hive.deleteBoxFromDisk()`:
/// after a widget under test has written to the box, closing it hangs
/// indefinitely in this environment (a pending write flush that never
/// completes). Each test file is its own process, so just delete the temp
/// directory on disk — no need to go through Hive to release the handles.
Future<void> disposeTestHive() async {
  await _tempDir?.delete(recursive: true);
  _tempDir = null;
}
