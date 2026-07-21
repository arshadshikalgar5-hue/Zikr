import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'hive_boxes.dart';

/// The five daily prayers, in order.
const namazPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

/// Key format used in the `namaz_tracker` Hive box: `yyyy-MM-dd` mapping to
/// the `List<String>` of prayer names completed that day. Public so a future
/// Progress feature can read historical entries the same way.
String namazTrackerKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

Set<String> _completedOn(Box box, DateTime date) {
  final stored = box.get(namazTrackerKey(date)) as List<dynamic>?;
  return stored?.cast<String>().toSet() ?? <String>{};
}

/// Which prayers are checked off today. Synchronous, never-await-the-write —
/// same pattern as the other Hive-backed notifiers in this app (see
/// AdhkarProgressNotifier).
class NamazTrackerNotifier extends Notifier<Set<String>> {
  Box get _box => Hive.box(HiveBoxes.namazTracker);

  @override
  Set<String> build() => _completedOn(_box, DateTime.now());

  void toggle(String prayer) {
    final updated = Set<String>.from(state);
    if (!updated.remove(prayer)) {
      updated.add(prayer);
    }
    _box.put(namazTrackerKey(DateTime.now()), updated.toList());
    state = updated;
  }
}

final namazTrackerProvider =
    NotifierProvider<NamazTrackerNotifier, Set<String>>(
      NamazTrackerNotifier.new,
    );

/// One day's completion snapshot, used to build the weekly/monthly views and
/// the streak count.
class DayCompletion {
  DayCompletion({required this.date, required this.completed});

  final DateTime date;
  final Set<String> completed;

  int get count => completed.length;
  bool get isFullyComplete => completed.length >= namazPrayers.length;
}

DayCompletion _dayCompletionFor(Box box, DateTime date) {
  return DayCompletion(date: date, completed: _completedOn(box, date));
}

/// Consecutive fully-complete days counting backward from today. An
/// unfinished "today" doesn't zero out a real streak — it only counts once
/// it's fully complete itself, otherwise the count starts from yesterday.
int _currentStreak(Box box) {
  var day = DateTime.now();
  if (!_dayCompletionFor(box, day).isFullyComplete) {
    day = day.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (_dayCompletionFor(box, day).isFullyComplete) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

List<DayCompletion> _lastNDays(Box box, int n) {
  final today = DateTime.now();
  return List.generate(n, (i) {
    final date = today.subtract(Duration(days: n - 1 - i));
    return _dayCompletionFor(box, date);
  });
}

/// Aggregate stats for the tracker UI: today's set, the last 7 days, the
/// current calendar month through today, and the current streak.
class NamazStats {
  NamazStats({
    required this.today,
    required this.week,
    required this.month,
    required this.currentStreak,
  });

  final DayCompletion today;
  final List<DayCompletion> week;
  final List<DayCompletion> month;
  final int currentStreak;
}

final namazStatsProvider = Provider<NamazStats>((ref) {
  ref.watch(namazTrackerProvider);
  final box = Hive.box(HiveBoxes.namazTracker);
  final now = DateTime.now();

  return NamazStats(
    today: _dayCompletionFor(box, now),
    week: _lastNDays(box, 7),
    month: List.generate(
      now.day,
      (i) => _dayCompletionFor(box, DateTime(now.year, now.month, i + 1)),
    ),
    currentStreak: _currentStreak(box),
  );
});
