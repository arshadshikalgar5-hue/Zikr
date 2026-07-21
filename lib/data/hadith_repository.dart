import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single entry from the bundled Hadith library (`assets/data/hadith.json`).
/// `category` is plain data, not an enum — new categories, or a 2nd hadith
/// in an existing one, need only a JSON edit, matching the Daily Duas model.
class HadithEntry {
  const HadithEntry({
    required this.id,
    required this.category,
    required this.arabic,
    required this.translation,
    required this.book,
    required this.authenticityNote,
    required this.reference,
  });

  final String id;
  final String category;
  final String arabic;
  final String translation;
  final String book;
  final String authenticityNote;
  final String reference;

  factory HadithEntry.fromJson(Map<String, dynamic> json) {
    return HadithEntry(
      id: json['id'] as String,
      category: json['category'] as String,
      arabic: json['arabic'] as String,
      translation: json['translation'] as String,
      book: json['book'] as String,
      authenticityNote: json['authenticityNote'] as String,
      reference: json['reference'] as String,
    );
  }
}

Future<List<HadithEntry>> loadHadith() async {
  final raw = await rootBundle.loadString('assets/data/hadith.json');
  final decoded = jsonDecode(raw) as List<dynamic>;
  return decoded
      .map((entry) => HadithEntry.fromJson(entry as Map<String, dynamic>))
      .toList();
}

final hadithProvider = FutureProvider<List<HadithEntry>>(
  (ref) => loadHadith(),
);

/// Distinct categories, in the order they first appear in the JSON.
List<String> hadithCategoriesOf(List<HadithEntry> hadith) {
  final seen = <String>{};
  return [
    for (final entry in hadith)
      if (seen.add(entry.category)) entry.category,
  ];
}
