import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/adhkar_progress_repository.dart';
import '../../data/adhkar_repository.dart';

class AdhkarScreen extends ConsumerWidget {
  const AdhkarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adhkar = ref.watch(adhkarProvider);
    final morningDone = ref.watch(morningAdhkarProgressProvider).length;
    final eveningDone = ref.watch(eveningAdhkarProgressProvider).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Adhkar')),
      body: adhkar.when(
        data: (allItems) {
          final morningTotal = allItems
              .where((item) => item.period == 'morning')
              .length;
          final eveningTotal = allItems
              .where((item) => item.period == 'evening')
              .length;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AdhkarPeriodCard(
                title: 'Morning Adhkar',
                icon: Icons.wb_sunny_outlined,
                completed: morningDone,
                total: morningTotal,
                onTap: () =>
                    context.push(AppRoutes.adhkarChecklist, extra: 'morning'),
              ),
              const SizedBox(height: 16),
              _AdhkarPeriodCard(
                title: 'Evening Adhkar',
                icon: Icons.nights_stay_outlined,
                completed: eveningDone,
                total: eveningTotal,
                onTap: () =>
                    context.push(AppRoutes.adhkarChecklist, extra: 'evening'),
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

class _AdhkarPeriodCard extends StatelessWidget {
  const _AdhkarPeriodCard({
    required this.title,
    required this.icon,
    required this.completed,
    required this.total,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final int completed;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isComplete = total > 0 && completed >= total;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isComplete ? colorScheme.secondary : colorScheme.primary)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isComplete ? Icons.check_circle : icon,
                  color: isComplete ? colorScheme.secondary : colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : completed / total,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed of $total completed today',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
