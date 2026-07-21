import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'hive_boxes.dart';

/// Which hadith ids are favorited, keyed directly by hadith id in the
/// `favorite_hadith` Hive box. Mirrors FavoriteDuasNotifier's pattern:
/// mutators are synchronous and never await the Box write.
class FavoriteHadithNotifier extends Notifier<Set<String>> {
  Box get _box => Hive.box(HiveBoxes.favoriteHadith);

  @override
  Set<String> build() => _box.keys.cast<String>().toSet();

  void toggle(String hadithId) {
    if (_box.containsKey(hadithId)) {
      _box.delete(hadithId);
    } else {
      _box.put(hadithId, true);
    }
    state = _box.keys.cast<String>().toSet();
  }
}

final favoriteHadithProvider =
    NotifierProvider<FavoriteHadithNotifier, Set<String>>(
      FavoriteHadithNotifier.new,
    );
