import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'hive_boxes.dart';

/// Which name ids are favorited, keyed directly by name id in the
/// `favorite_names` Hive box. Mirrors FavoriteDuasNotifier's pattern:
/// mutators are synchronous and never await the Box write.
class FavoriteNamesNotifier extends Notifier<Set<String>> {
  Box get _box => Hive.box(HiveBoxes.favoriteNames);

  @override
  Set<String> build() => _box.keys.cast<String>().toSet();

  void toggle(String nameId) {
    if (_box.containsKey(nameId)) {
      _box.delete(nameId);
    } else {
      _box.put(nameId, true);
    }
    state = _box.keys.cast<String>().toSet();
  }
}

final favoriteNamesProvider =
    NotifierProvider<FavoriteNamesNotifier, Set<String>>(
      FavoriteNamesNotifier.new,
    );
