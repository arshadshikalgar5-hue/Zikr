import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cities_repository.dart';
import '../../data/prayer_location_repository.dart';
import 'city_search_delegate.dart';

/// Shared "resolve a location" flow for any screen that needs the user's
/// coordinates (Prayer Times, Qibla) — both read from and write to the same
/// [prayerLocationProvider], so picking a location on one screen carries
/// over to the other.
mixin LocationPickerMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool locating = false;

  Future<void> useDeviceLocation() async {
    setState(() => locating = true);
    final error = await ref
        .read(prayerLocationProvider.notifier)
        .useDeviceLocation();
    if (!mounted) return;
    setState(() => locating = false);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> chooseCity() async {
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

  void showChangeLocationSheet() {
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
                useDeviceLocation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Choose a City'),
              onTap: () {
                Navigator.of(context).pop();
                chooseCity();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty-state prompt shown until a location has been resolved.
class LocationPickerPrompt extends StatelessWidget {
  const LocationPickerPrompt({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.locating,
    required this.onUseDeviceLocation,
    required this.onChooseCity,
  });

  final IconData icon;
  final String title;
  final String message;
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
            Icon(icon, size: 64, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
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

/// Card showing the resolved location's label with a "Change" action.
class CachedLocationCard extends StatelessWidget {
  const CachedLocationCard({
    super.key,
    required this.location,
    required this.onChange,
  });

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
