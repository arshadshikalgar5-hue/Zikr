import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'hive_boxes.dart';

/// Which dua ids are favorited, keyed directly by dua id (a String, so no
/// int-key-range concern) in the `favorite_duas` Hive box.
///
/// Mutators are synchronous and never await the Box write — Box updates its
/// in-memory state synchronously and flushes to disk in the background;
/// awaiting that flush inside a widget callback hangs under `flutter test`
/// (see CustomDhikrNotifier for the same pattern and why).
class FavoriteDuasNotifier extends Notifier<Set<String>> {
  Box get _box => Hive.box(HiveBoxes.favoriteDuas);

  @override
  Set<String> build() => _box.keys.cast<String>().toSet();

  void toggle(String duaId) {
    if (_box.containsKey(duaId)) {
      _box.delete(duaId);
    } else {
      _box.put(duaId, true);
    }
    state = _box.keys.cast<String>().toSet();
  }
}

final favoriteDuasProvider =
    NotifierProvider<FavoriteDuasNotifier, Set<String>>(
      FavoriteDuasNotifier.new,
    );
