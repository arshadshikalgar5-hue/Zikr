import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

import 'cities_repository.dart';
import 'hive_boxes.dart';

/// A resolved prayer-time location, cached in the `prayer_settings` Hive box
/// under the `location` key so prayer times can still be computed offline
/// after the first successful lookup (device GPS or manual city).
///
/// [timezone] is only meaningful when [isManual] is true — a device-sourced
/// location relies on the device's own system timezone instead (see
/// prayer_times_repository.dart).
class CachedLocation {
  const CachedLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.isManual,
    this.timezone = '',
  });

  final double latitude;
  final double longitude;
  final String label;
  final bool isManual;
  final String timezone;

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
    'label': label,
    'isManual': isManual,
    'timezone': timezone,
  };

  factory CachedLocation.fromMap(Map<dynamic, dynamic> map) => CachedLocation(
    latitude: (map['latitude'] as num).toDouble(),
    longitude: (map['longitude'] as num).toDouble(),
    label: map['label'] as String,
    isManual: map['isManual'] as bool,
    timezone: map['timezone'] as String? ?? '',
  );
}

/// The current prayer-time location — read from cache on startup, updated by
/// [useDeviceLocation] or [useCity]. Box writes are synchronous and never
/// awaited (same pattern as every other Hive-backed notifier in this app);
/// only the device-location lookup itself is async.
class PrayerLocationNotifier extends Notifier<CachedLocation?> {
  Box get _box => Hive.box(HiveBoxes.prayerSettings);

  @override
  CachedLocation? build() {
    final stored = _box.get('location') as Map<dynamic, dynamic>?;
    return stored == null ? null : CachedLocation.fromMap(stored);
  }

  /// Attempts to resolve the device's current GPS location. Returns null on
  /// success, or a user-facing error message on failure.
  Future<String?> useDeviceLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return 'Location services are turned off. Turn them on, or pick a '
          'city manually.';
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return 'Location permission was denied. Pick a city manually instead.';
    }
    if (permission == LocationPermission.deniedForever) {
      return 'Location permission is permanently denied. Enable it from '
          'app settings, or pick a city manually.';
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final location = CachedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        label: 'Current Location',
        isManual: false,
      );
      _box.put('location', location.toMap());
      state = location;
      return null;
    } catch (_) {
      return 'Could not determine your location. Pick a city manually '
          'instead.';
    }
  }

  void useCity(CityEntry city) {
    final location = CachedLocation(
      latitude: city.latitude,
      longitude: city.longitude,
      label: city.label,
      isManual: true,
      timezone: city.timezone,
    );
    _box.put('location', location.toMap());
    state = location;
  }
}

final prayerLocationProvider =
    NotifierProvider<PrayerLocationNotifier, CachedLocation?>(
      PrayerLocationNotifier.new,
    );
