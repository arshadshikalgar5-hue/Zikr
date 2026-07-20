import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single entry from the bundled dhikr library (`assets/data/dhikr.json`).
class DhikrEntry {
  const DhikrEntry({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.reference,
  });

  final String id;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String reference;

  factory DhikrEntry.fromJson(Map<String, dynamic> json) {
    return DhikrEntry(
      id: json['id'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: json['meaning'] as String,
      reference: json['reference'] as String,
    );
  }
}

Future<List<DhikrEntry>> loadDhikrLibrary() async {
  final raw = await rootBundle.loadString('assets/data/dhikr.json');
  final decoded = jsonDecode(raw) as List<dynamic>;
  return decoded
      .map((entry) => DhikrEntry.fromJson(entry as Map<String, dynamic>))
      .toList();
}

final dhikrLibraryProvider = FutureProvider<List<DhikrEntry>>(
  (ref) => loadDhikrLibrary(),
);
