import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/dhikr_repository.dart';

class DhikrLibraryScreen extends ConsumerWidget {
  const DhikrLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(dhikrLibraryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dhikr Library')),
      body: library.when(
        data: (entries) => ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return ListTile(
              title: Text(entry.transliteration),
              subtitle: Text(
                entry.meaning,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  context.push(AppRoutes.dhikrDetail, extra: entry),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => const Center(
          child: Text('Could not load the dhikr library.'),
        ),
      ),
    );
  }
}
