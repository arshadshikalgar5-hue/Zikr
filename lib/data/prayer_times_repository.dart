import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import 'prayer_location_repository.dart';
import 'prayer_settings_repository.dart';

/// Today's five prayer times plus sunrise, in the location's own local time
/// — the device's system time for a device-sourced location, or the picked
/// city's IANA timezone for a manual one (see [computePrayerTimes]).
class DailyPrayerTimes {
  DailyPrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  /// The 5 daily prayers in order, excluding sunrise (not a prayer time).
  List<MapEntry<String, DateTime>> get prayers => [
    MapEntry('Fajr', fajr),
    MapEntry('Dhuhr', dhuhr),
    MapEntry('Asr', asr),
    MapEntry('Maghrib', maghrib),
    MapEntry('Isha', isha),
  ];
}

/// Converts a UTC prayer time into the location's own wall-clock time.
DateTime _toDisplayTime(DateTime utc, CachedLocation location) {
  if (location.isManual && location.timezone.isNotEmpty) {
    return tz.TZDateTime.from(utc, tz.getLocation(location.timezone));
  }
  return utc.toLocal();
}

/// Pure astronomical calculation — coordinates and today's date in, prayer
/// times out. No network access of any kind, so this works fully offline
/// once a location has been resolved once and cached.
DailyPrayerTimes computePrayerTimes(
  CachedLocation location,
  PrayerSettings settings,
) {
  final coordinates = Coordinates(location.latitude, location.longitude);
  final params = settings.method.getParameters()..madhab = settings.madhab;
  final times = PrayerTimes.utc(
    coordinates,
    DateComponents.from(DateTime.now()),
    params,
  );
  return DailyPrayerTimes(
    fajr: _toDisplayTime(times.fajr, location),
    sunrise: _toDisplayTime(times.sunrise, location),
    dhuhr: _toDisplayTime(times.dhuhr, location),
    asr: _toDisplayTime(times.asr, location),
    maghrib: _toDisplayTime(times.maghrib, location),
    isha: _toDisplayTime(times.isha, location),
  );
}

/// Null when no location has been resolved yet (first launch, before the
/// user grants location access or picks a city).
final todayPrayerTimesProvider = Provider<DailyPrayerTimes?>((ref) {
  final location = ref.watch(prayerLocationProvider);
  final settings = ref.watch(prayerSettingsProvider);
  if (location == null) return null;
  return computePrayerTimes(location, settings);
});
