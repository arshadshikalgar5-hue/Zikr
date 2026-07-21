import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/prayer_notifications_repository.dart';
import '../../data/prayer_settings_repository.dart';

class PrayerSettingsScreen extends ConsumerWidget {
  const PrayerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(prayerSettingsProvider);
    final notifier = ref.read(prayerSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Calculation Method'),
          RadioGroup<CalculationMethod>(
            groupValue: settings.method,
            onChanged: (method) {
              if (method != null) notifier.setMethod(method);
            },
            child: Column(
              children: [
                for (final entry in calculationMethodLabels.entries)
                  RadioListTile<CalculationMethod>(
                    title: Text(entry.value),
                    value: entry.key,
                  ),
              ],
            ),
          ),
          const Divider(),
          const _SectionHeader('Madhab (Asr calculation)'),
          RadioGroup<Madhab>(
            groupValue: settings.madhab,
            onChanged: (madhab) {
              if (madhab != null) notifier.setMadhab(madhab);
            },
            child: Column(
              children: [
                for (final entry in madhabLabels.entries)
                  RadioListTile<Madhab>(title: Text(entry.value), value: entry.key),
              ],
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Prayer Time Notifications'),
            subtitle: const Text(
              "Get notified when each of today's remaining prayer times begins.",
            ),
            value: settings.notificationsEnabled,
            onChanged: (enabled) async {
              if (enabled) {
                await requestPrayerNotificationPermissions();
              }
              notifier.setNotificationsEnabled(enabled);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
