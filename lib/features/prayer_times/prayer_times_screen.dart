import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/cities_repository.dart';
import '../../data/prayer_location_repository.dart';
import '../../data/prayer_notifications_repository.dart';
import '../../data/prayer_settings_repository.dart';
import '../../data/prayer_times_repository.dart';
import 'city_search_delegate.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen> {
  bool _locating = false;

  Future<void> _useDeviceLocation() async {
    setState(() => _locating = true);
    final error = await ref
        .read(prayerLocationProvider.notifier)
        .useDeviceLocation();
    if (!mounted) return;
    setState(() => _locating = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _chooseCity() async {
    final cities = await ref.read(citiesProvider.future);
    if (!mounted) return;
    final city = await showSearch<CityEntry?>(
      context: context,
      delegate: CitySearchDelegate(cities),
    );
    if (city != null) {
      ref.read(prayerLocationProvider.notifier).useCity(city);
    }
  }

  void _showChangeLocationSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Use My Location'),
              onTap: () {
                Navigator.of(context).pop();
                _useDeviceLocation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Choose a City'),
              onTap: () {
                Navigator.of(context).pop();
                _chooseCity();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(prayerLocationProvider);
    final times = ref.watch(todayPrayerTimesProvider);

    ref.listen(todayPrayerTimesProvider, (previous, next) {
      final enabled = ref.read(prayerSettingsProvider).notificationsEnabled;
      if (next != null && enabled) {
        scheduleTodayPrayerNotifications(next);
      }
    });
    ref.listen(prayerSettingsProvider.select((s) => s.notificationsEnabled), (
      previous,
      enabled,
    ) {
      final current = ref.read(todayPrayerTimesProvider);
      if (enabled && current != null) {
        scheduleTodayPrayerNotifications(current);
      } else if (!enabled) {
        cancelAllPrayerNotifications();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.prayerSettings),
          ),
        ],
      ),
      body: (location == null || times == null)
          ? _EmptyLocationState(
              locating: _locating,
              onUseDeviceLocation: _useDeviceLocation,
              onChooseCity: _chooseCity,
            )
          : _PrayerTimesBody(
              location: location,
              times: times,
              onChangeLocation: _showChangeLocationSheet,
            ),
    );
  }
}

class _EmptyLocationState extends StatelessWidget {
  const _EmptyLocationState({
    required this.locating,
    required this.onUseDeviceLocation,
    required this.onChooseCity,
  });

  final bool locating;
  final VoidCallback onUseDeviceLocation;
  final VoidCallback onChooseCity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_outlined,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              "Find today's prayer times",
              style: textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Use your device location, or pick a city manually. Every '
              "calculation happens on-device — nothing is sent anywhere.",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: locating ? null : onUseDeviceLocation,
              icon: locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: const Text('Use My Location'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onChooseCity,
              icon: const Icon(Icons.location_city),
              label: const Text('Choose a City'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerTimesBody extends StatelessWidget {
  const _PrayerTimesBody({
    required this.location,
    required this.times,
    required this.onChangeLocation,
  });

  final CachedLocation location;
  final DailyPrayerTimes times;
  final VoidCallback onChangeLocation;

  MapEntry<String, DateTime>? get _nextPrayer {
    final now = DateTime.now();
    for (final prayer in times.prayers) {
      if (prayer.value.isAfter(now)) return prayer;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _nextPrayer;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LocationCard(location: location, onChange: onChangeLocation),
        const SizedBox(height: 16),
        if (upcoming != null)
          _NextPrayerBanner(name: upcoming.key, time: upcoming.value)
        else
          const _NextPrayerBanner(
            name: null,
            time: null,
            fallbackText: "Isha has passed — next up is tomorrow's Fajr.",
          ),
        const SizedBox(height: 16),
        _PrayerRow(name: 'Fajr', time: times.fajr, icon: Icons.wb_twilight),
        _PrayerRow(
          name: 'Sunrise',
          time: times.sunrise,
          icon: Icons.light_mode,
        ),
        _PrayerRow(
          name: 'Dhuhr',
          time: times.dhuhr,
          icon: Icons.wb_sunny_outlined,
        ),
        _PrayerRow(name: 'Asr', time: times.asr, icon: Icons.brightness_5),
        _PrayerRow(
          name: 'Maghrib',
          time: times.maghrib,
          icon: Icons.nights_stay_outlined,
        ),
        _PrayerRow(name: 'Isha', time: times.isha, icon: Icons.dark_mode),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location, required this.onChange});

  final CachedLocation location;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              location.isManual ? Icons.location_city : Icons.my_location,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(location.label, style: textTheme.titleMedium),
            ),
            TextButton.icon(
              onPressed: onChange,
              icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
              label: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextPrayerBanner extends StatelessWidget {
  const _NextPrayerBanner({
    required this.name,
    required this.time,
    this.fallbackText,
  });

  final String? name;
  final DateTime? time;
  final String? fallbackText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active_outlined, color: colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: name != null && time != null
                ? Text(
                    'Next: $name at ${_formatTime(time!)}',
                    style: textTheme.titleSmall,
                  )
                : Text(fallbackText ?? '', style: textTheme.titleSmall),
          ),
        ],
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({required this.name, required this.time, required this.icon});

  final String name;
  final DateTime time;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(name, style: textTheme.titleMedium),
        trailing: Text(_formatTime(time), style: textTheme.titleMedium),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final hour24 = time.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = hour24 < 12 ? 'AM' : 'PM';
  return '$hour12:$minute $period';
}
