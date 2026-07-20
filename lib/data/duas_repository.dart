import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single entry from the bundled Daily Duas library
/// (`assets/data/duas.json`). `category` is plain data, not an enum — new
/// categories can be added to the JSON with no code changes; the UI derives
/// its category list from whatever values are present.
class DuaEntry {
  const DuaEntry({
    required this.id,
    required this.category,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
  });

  final String id;
  final String category;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;

  factory DuaEntry.fromJson(Map<String, dynamic> json) {
    return DuaEntry(
      id: json['id'] as String,
      category: json['category'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      reference: json['reference'] as String,
    );
  }
}

Future<List<DuaEntry>> loadDuas() async {
  final raw = await rootBundle.loadString('assets/data/duas.json');
  final decoded = jsonDecode(raw) as List<dynamic>;
  return decoded
      .map((entry) => DuaEntry.fromJson(entry as Map<String, dynamic>))
      .toList();
}

final duasProvider = FutureProvider<List<DuaEntry>>((ref) => loadDuas());

/// Distinct categories, in the order they first appear in the JSON —
/// letting the content file control category order too.
List<String> duaCategoriesOf(List<DuaEntry> duas) {
  final seen = <String>{};
  return [
    for (final dua in duas)
      if (seen.add(dua.category)) dua.category,
  ];
}
