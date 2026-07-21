import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single entry from the bundled 99 Names of Allah
/// (`assets/data/names.json`), in the traditional order.
class NameEntry {
  const NameEntry({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.explanation,
  });

  final String id;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String explanation;

  factory NameEntry.fromJson(Map<String, dynamic> json) {
    return NameEntry(
      id: json['id'] as String,
      arabic: json['arabic'] as String,
      transliteration: json['transliteration'] as String,
      meaning: json['meaning'] as String,
      explanation: json['explanation'] as String,
    );
  }
}

Future<List<NameEntry>> loadNames() async {
  final raw = await rootBundle.loadString('assets/data/names.json');
  final decoded = jsonDecode(raw) as List<dynamic>;
  return decoded
      .map((entry) => NameEntry.fromJson(entry as Map<String, dynamic>))
      .toList();
}

final namesProvider = FutureProvider<List<NameEntry>>((ref) => loadNames());
