import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'hive_boxes.dart';

/// Key format used in the `adhkar_progress` Hive box: `<period>_<yyyy-MM-dd>`
/// mapping to the `List<String>` of completed item ids for that day. Public
/// so a future Progress feature can read historical entries the same way.
String adhkarProgressKey(String period, DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${period}_$y-$m-$d';
}

/// Which item ids are checked off today for a given period ("morning" or
/// "evening"). One box shared by both; each period gets its own key so
/// morning and evening progress don't collide.
///
/// Synchronous, never-await-the-write — same pattern as the other
/// Hive-backed notifiers in this app (see CustomDhikrNotifier).
class AdhkarProgressNotifier extends Notifier<Set<String>> {
  AdhkarProgressNotifier(this.period);

  final String period;

  Box get _box => Hive.box(HiveBoxes.adhkarProgress);
  String get _todayKey => adhkarProgressKey(period, DateTime.now());

  @override
  Set<String> build() {
    final stored = _box.get(_todayKey) as List<dynamic>?;
    return stored?.cast<String>().toSet() ?? <String>{};
  }

  void toggle(String itemId) {
    final updated = Set<String>.from(state);
    if (!updated.remove(itemId)) {
      updated.add(itemId);
    }
    _box.put(_todayKey, updated.toList());
    state = updated;
  }
}

final morningAdhkarProgressProvider =
    NotifierProvider<AdhkarProgressNotifier, Set<String>>(
      () => AdhkarProgressNotifier('morning'),
    );

final eveningAdhkarProgressProvider =
    NotifierProvider<AdhkarProgressNotifier, Set<String>>(
      () => AdhkarProgressNotifier('evening'),
    );
