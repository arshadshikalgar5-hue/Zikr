import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'hive_boxes.dart';

/// A dhikr/dua the user has written themselves, stored in the `custom_dhikr`
/// Hive box (one Map per entry, keyed by a small sequential id — no
/// TypeAdapter needed for plain string fields).
class CustomDhikrEntry {
  const CustomDhikrEntry({
    required this.id,
    required this.text,
    this.transliteration,
    this.meaning,
  });

  final int id;
  final String text;
  final String? transliteration;
  final String? meaning;

  /// What shows in the Tasbeeh dropdown and list rows: the transliteration
  /// when given, otherwise the text itself.
  String get displayLabel =>
      (transliteration != null && transliteration!.isNotEmpty)
      ? transliteration!
      : text;

  Map<String, dynamic> toMap() => {
    'text': text,
    'transliteration': transliteration,
    'meaning': meaning,
  };

  factory CustomDhikrEntry.fromMap(int id, Map<dynamic, dynamic> map) {
    return CustomDhikrEntry(
      id: id,
      text: map['text'] as String,
      transliteration: map['transliteration'] as String?,
      meaning: map['meaning'] as String?,
    );
  }

  CustomDhikrEntry copyWith({
    String? text,
    String? transliteration,
    String? meaning,
  }) {
    return CustomDhikrEntry(
      id: id,
      text: text ?? this.text,
      transliteration: transliteration ?? this.transliteration,
      meaning: meaning ?? this.meaning,
    );
  }
}

class CustomDhikrNotifier extends Notifier<List<CustomDhikrEntry>> {
  Box get _box => Hive.box(HiveBoxes.customDhikr);

  @override
  List<CustomDhikrEntry> build() => _readAll();

  List<CustomDhikrEntry> _readAll() {
    final entries = [
      for (final key in _box.keys)
        CustomDhikrEntry.fromMap(key as int, _box.get(key) as Map),
    ];
    entries.sort((a, b) => a.id.compareTo(b.id));
    return entries;
  }

  // These don't await the Hive write (matching TasbeehNotifier's pattern):
  // Box's in-memory state updates synchronously, so `state = _readAll()`
  // is immediately consistent, and the disk flush finishes in the
  // background. Awaiting it here isn't necessary and doesn't resolve
  // inside a widget test's FakeAsync zone, hanging any caller that awaits.
  void add({required String text, String? transliteration, String? meaning}) {
    // Box.put() with an explicit, small sequential key — not Box.add()'s
    // auto-increment (observed to hang under this project's test runner)
    // and not a timestamp (Hive int keys must fit in 0 - 0xFFFFFFFF).
    final keys = _box.keys.cast<int>();
    final id = keys.isEmpty ? 0 : keys.reduce((a, b) => a > b ? a : b) + 1;
    _box.put(id, {
      'text': text.trim(),
      'transliteration': _blankToNull(transliteration),
      'meaning': _blankToNull(meaning),
    });
    state = _readAll();
  }

  void update(CustomDhikrEntry entry) {
    _box.put(entry.id, entry.toMap());
    state = _readAll();
  }

  void delete(int id) {
    _box.delete(id);
    state = _readAll();
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

final customDhikrProvider =
    NotifierProvider<CustomDhikrNotifier, List<CustomDhikrEntry>>(
      CustomDhikrNotifier.new,
    );
