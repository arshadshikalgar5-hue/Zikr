import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/adhkar_progress_repository.dart';
import '../../data/adhkar_repository.dart';

class AdhkarChecklistScreen extends ConsumerWidget {
  const AdhkarChecklistScreen({super.key, required this.period});

  /// "morning" or "evening" — matches an [AdhkarEntry.period] value.
  final String period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhkar = ref.watch(adhkarProvider);
    final progressProvider = period == 'morning'
        ? morningAdhkarProgressProvider
        : eveningAdhkarProgressProvider;
    final completed = ref.watch(progressProvider);
    final notifier = ref.read(progressProvider.notifier);
    final title = period == 'morning' ? 'Morning Adhkar' : 'Evening Adhkar';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: adhkar.when(
        data: (allItems) {
          final items = allItems
              .where((item) => item.period == period)
              .toList();
          final progress = items.isEmpty ? 0.0 : completed.length / items.length;

          return Column(
            children: [
              ClipRRect(
                child: LinearProgressIndicator(value: progress, minHeight: 6),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isDone = completed.contains(item.id);
                    return _AdhkarItemCard(
                      item: item,
                      isDone: isDone,
                      onToggle: () => notifier.toggle(item.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Could not load adhkar.')),
      ),
    );
  }
}

class _AdhkarItemCard extends StatelessWidget {
  const _AdhkarItemCard({
    required this.item,
    required this.isDone,
    required this.onToggle,
  });

  final AdhkarEntry item;
  final bool isDone;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final strike = isDone ? TextDecoration.lineThrough : null;
    final fadedColor = isDone ? colorScheme.onSurfaceVariant : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: isDone, onChanged: (_) => onToggle()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.arabic,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: textTheme.titleLarge?.copyWith(
                        height: 1.7,
                        color: fadedColor,
                        decoration: strike,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.transliteration,
                      style: textTheme.bodyMedium?.copyWith(
                        color: fadedColor ?? colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: strike,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.translation,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        decoration: strike,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (item.repeat > 1) ...[
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text('×${item.repeat}'),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            item.reference,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
