import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/namaz_tracker_repository.dart';

const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class NamazTrackerScreen extends StatelessWidget {
  const NamazTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Namaz Tracker'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daily'),
              Tab(text: 'Weekly'),
              Tab(text: 'Monthly'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_DailyTab(), _WeeklyTab(), _MonthlyTab()],
        ),
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.local_fire_department, color: colorScheme.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                streak == 0
                    ? 'No streak yet — complete all 5 prayers today to start one.'
                    : '$streak day${streak == 1 ? '' : 's'} streak of all 5 prayers',
                style: textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTab extends ConsumerWidget {
  const _DailyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(namazTrackerProvider);
    final notifier = ref.read(namazTrackerProvider.notifier);
    final streak = ref.watch(namazStatsProvider).currentStreak;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StreakBanner(streak: streak),
        const SizedBox(height: 16),
        for (final prayer in namazPrayers) ...[
          _PrayerCard(
            prayer: prayer,
            isDone: completed.contains(prayer),
            onToggle: () => notifier.toggle(prayer),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.prayer,
    required this.isDone,
    required this.onToggle,
  });

  final String prayer;
  final bool isDone;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Checkbox(value: isDone, onChanged: (_) => onToggle()),
              const SizedBox(width: 8),
              Text(
                prayer,
                style: textTheme.titleMedium?.copyWith(
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? colorScheme.onSurfaceVariant : null,
                ),
              ),
              const Spacer(),
              if (isDone) Icon(Icons.check_circle, color: colorScheme.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyTab extends ConsumerWidget {
  const _WeeklyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final week = ref.watch(namazStatsProvider).week;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: week.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _DayRow(day: week[index]),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final DayCompletion day;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isToday = _isSameDay(day.date, DateTime.now());
    final total = namazPrayers.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              child: Text(
                isToday
                    ? 'Today'
                    : '${_weekdayLabels[day.date.weekday - 1]} ${day.date.day}',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: day.count / total,
                  minHeight: 8,
                  color: day.isFullyComplete ? colorScheme.secondary : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('${day.count}/$total', style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _MonthlyTab extends ConsumerWidget {
  const _MonthlyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(namazStatsProvider).month;
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Monday = 0 .. Sunday = 6, so the grid lines up under the weekday header.
    final leadingBlanks = DateTime(now.year, now.month, 1).weekday - 1;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('${_monthNames[now.month - 1]} ${now.year}', style: textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingBlanks + month.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
          ),
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = month[index - leadingBlanks];
            final isToday = _isSameDay(day.date, now);
            final fraction = day.count / namazPrayers.length;
            final background = fraction == 0
                ? Colors.transparent
                : colorScheme.secondary.withValues(alpha: 0.2 + fraction * 0.6);

            return Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  color: background,
                  shape: BoxShape.circle,
                  border: isToday
                      ? Border.all(color: colorScheme.primary, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text('${day.date.day}', style: textTheme.bodySmall),
              ),
            );
          },
        ),
      ],
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
