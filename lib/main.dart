import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'data/hive_boxes.dart';
import 'data/prayer_notifications_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(HiveBoxes.tasbeeh);
  await Hive.openBox(HiveBoxes.customDhikr);
  await Hive.openBox(HiveBoxes.favoriteDuas);
  await Hive.openBox(HiveBoxes.adhkarProgress);
  await Hive.openBox(HiveBoxes.favoriteHadith);
  await Hive.openBox(HiveBoxes.favoriteNames);
  await Hive.openBox(HiveBoxes.namazTracker);
  await Hive.openBox(HiveBoxes.prayerSettings);

  tz.initializeTimeZones();
  await initPrayerNotifications();

  runApp(const ProviderScope(child: ZikrApp()));
}
