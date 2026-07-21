import 'package:adhan/adhan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'hive_boxes.dart';

/// User-chosen prayer calculation settings, persisted in the
/// `prayer_settings` Hive box (alongside the cached location — see
/// prayer_location_repository.dart — under separate keys).
class PrayerSettings {
  const PrayerSettings({
    this.method = CalculationMethod.muslim_world_league,
    this.madhab = Madhab.shafi,
    this.notificationsEnabled = false,
  });

  final CalculationMethod method;
  final Madhab madhab;
  final bool notificationsEnabled;

  PrayerSettings copyWith({
    CalculationMethod? method,
    Madhab? madhab,
    bool? notificationsEnabled,
  }) {
    return PrayerSettings(
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

/// Synchronous, never-await-the-write — same pattern as every other
/// Hive-backed notifier in this app.
class PrayerSettingsNotifier extends Notifier<PrayerSettings> {
  Box get _box => Hive.box(HiveBoxes.prayerSettings);

  @override
  PrayerSettings build() {
    final methodName = _box.get('method') as String?;
    final madhabName = _box.get('madhab') as String?;
    final notificationsEnabled =
        _box.get('notificationsEnabled') as bool? ?? false;
    return PrayerSettings(
      method: CalculationMethod.values.firstWhere(
        (m) => m.name == methodName,
        orElse: () => CalculationMethod.muslim_world_league,
      ),
      madhab: Madhab.values.firstWhere(
        (m) => m.name == madhabName,
        orElse: () => Madhab.shafi,
      ),
      notificationsEnabled: notificationsEnabled,
    );
  }

  void setMethod(CalculationMethod method) {
    _box.put('method', method.name);
    state = state.copyWith(method: method);
  }

  void setMadhab(Madhab madhab) {
    _box.put('madhab', madhab.name);
    state = state.copyWith(madhab: madhab);
  }

  void setNotificationsEnabled(bool enabled) {
    _box.put('notificationsEnabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }
}

final prayerSettingsProvider =
    NotifierProvider<PrayerSettingsNotifier, PrayerSettings>(
      PrayerSettingsNotifier.new,
    );

/// Human-readable labels for the calculation methods offered in settings —
/// a curated subset of [CalculationMethod] rather than the full enum (e.g.
/// `other` is excluded, since it has no meaningful angle values on its own).
const calculationMethodLabels = {
  CalculationMethod.muslim_world_league: 'Muslim World League',
  CalculationMethod.egyptian: 'Egyptian General Authority of Survey',
  CalculationMethod.karachi: 'University of Islamic Sciences, Karachi',
  CalculationMethod.umm_al_qura: 'Umm al-Qura University, Makkah',
  CalculationMethod.dubai: 'Dubai (Gulf Region)',
  CalculationMethod.moon_sighting_committee: 'Moonsighting Committee',
  CalculationMethod.north_america: 'Islamic Society of North America',
  CalculationMethod.kuwait: 'Kuwait',
  CalculationMethod.qatar: 'Qatar',
  CalculationMethod.singapore: 'Singapore',
  CalculationMethod.turkey: 'Diyanet (Turkey)',
  CalculationMethod.tehran: 'University of Tehran',
};

const madhabLabels = {Madhab.shafi: 'Shafi (Standard)', Madhab.hanafi: 'Hanafi'};
