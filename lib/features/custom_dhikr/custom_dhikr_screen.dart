import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/custom_dhikr_repository.dart';

class CustomDhikrScreen extends ConsumerWidget {
  const CustomDhikrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(customDhikrProvider);
    final notifier = ref.read(customDhikrProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Dhikr')),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No custom dhikr yet. Tap + to add your own.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(
                      Icons.delete_outline,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  confirmDismiss: (_) => _confirmDelete(context),
                  onDismissed: (_) => notifier.delete(entry.id),
                  child: ListTile(
                    title: Text(entry.displayLabel),
                    subtitle: entry.meaning != null
                        ? Text(
                            entry.meaning!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push(AppRoutes.customDhikrForm, extra: entry),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.customDhikrForm),
        tooltip: 'Add custom dhikr',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this dhikr?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
