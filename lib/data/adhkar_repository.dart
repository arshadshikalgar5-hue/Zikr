import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single entry from the bundled Morning/Evening Adhkar
/// (`assets/data/adhkar.json`). `period` is plain data ("morning" or
/// "evening"), not an enum — matches the data-driven approach used for
/// dua categories.
class AdhkarEntry {
  const AdhkarEntry({
    required this.id,
    required this.period,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
    required this.repeat,
  });

  final String id;
  final String period;
  final String arabic;
  final String transliteration;
  final String translation;
  final String reference;

  /// How many times this is meant to be recited (e.g. 3, 7, 100). 1 if the
  /// JSON omits it.
  final int repeat;

  factory AdhkarEntry.fromJson(Map<String, dynamic> json) {
    return AdhkarEntry(
      id: json['id'] as String,
      period: json['period'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      reference: json['reference'] as String,
      repeat: (json['repeat'] as num?)?.toInt() ?? 1,
    );
  }
}

Future<List<AdhkarEntry>> loadAdhkar() async {
  final raw = await rootBundle.loadString('assets/data/adhkar.json');
  final decoded = jsonDecode(raw) as List<dynamic>;
  return decoded
      .map((entry) => AdhkarEntry.fromJson(entry as Map<String, dynamic>))
      .toList();
}

final adhkarProvider = FutureProvider<List<AdhkarEntry>>(
  (ref) => loadAdhkar(),
);
