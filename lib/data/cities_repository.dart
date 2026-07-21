import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A bundled major city usable as a manual location fallback when device
/// location isn't available. [timezone] is an IANA id (e.g. "Asia/Karachi")
/// so prayer times for a manually-picked city can be shown in that city's
/// own local time, independent of the device's timezone.
class CityEntry {
  const CityEntry({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  factory CityEntry.fromJson(Map<String, dynamic> json) {
    return CityEntry(
      name: json['name'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
    );
  }

  String get label => '$name, $country';
}

Future<List<CityEntry>> loadCities() async {
  final raw = await rootBundle.loadString('assets/data/cities.json');
  final list = jsonDecode(raw) as List<dynamic>;
  return list
      .map((e) => CityEntry.fromJson(e as Map<String, dynamic>))
      .toList();
}

final citiesProvider = FutureProvider<List<CityEntry>>((ref) => loadCities());
