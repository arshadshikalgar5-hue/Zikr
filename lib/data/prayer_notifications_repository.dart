import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'prayer_times_repository.dart';

final _plugin = FlutterLocalNotificationsPlugin();

/// Sets up the local notifications plugin. Call once at app startup, after
/// `tz.initializeTimeZones()`.
Future<void> initPrayerNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await _plugin.initialize(settings: settings);
}

/// Requests the runtime permissions notifications need on Android 13+
/// (POST_NOTIFICATIONS) and for exact-time alarms on Android 12+. Both are
/// no-ops on platforms/versions that don't require them.
Future<void> requestPrayerNotificationPermissions() async {
  final android = _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await android?.requestNotificationsPermission();
  await android?.requestExactAlarmsPermission();
}

const _channelId = 'prayer_times';
const _channelName = 'Prayer Time Reminders';

/// Cancels any previously-scheduled reminders and schedules one-off
/// notifications for each of today's remaining prayers. Prayer times shift
/// by a few minutes daily, so this is deliberately "today only" rather than
/// a recurring schedule — call it again whenever prayer times or settings
/// change (e.g. on app open) to keep it current.
Future<void> scheduleTodayPrayerNotifications(DailyPrayerTimes times) async {
  await _plugin.cancelAll();

  final now = DateTime.now();
  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifies you when each prayer time begins.',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  var id = 0;
  for (final prayer in times.prayers) {
    if (prayer.value.isBefore(now)) continue;
    try {
      await _plugin.zonedSchedule(
        id: id++,
        scheduledDate: tz.TZDateTime.from(prayer.value, tz.UTC),
        title: '${prayer.key} Prayer Time',
        body: "It's time for ${prayer.key} prayer.",
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Exact-alarm permission may be missing on this device; skip that
      // prayer's reminder rather than failing the whole batch.
    }
  }
}

Future<void> cancelAllPrayerNotifications() => _plugin.cancelAll();
