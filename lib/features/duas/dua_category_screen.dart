import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/duas_repository.dart';
import '../../data/favorite_duas_repository.dart';

class DuaCategoryScreen extends ConsumerWidget {
  const DuaCategoryScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duas = ref.watch(duasProvider);
    final favorites = ref.watch(favoriteDuasProvider);
    final favoritesNotifier = ref.read(favoriteDuasProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: duas.when(
        data: (allDuas) {
          final entries = allDuas
              .where((dua) => dua.category == category)
              .toList();
          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final dua = entries[index];
              final isFavorite = favorites.contains(dua.id);
              return ListTile(
                title: Text(dua.transliteration),
                subtitle: Text(
                  dua.translation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: isFavorite
                      ? Theme.of(context).colorScheme.secondary
                      : null,
                  tooltip: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: () => favoritesNotifier.toggle(dua.id),
                ),
                onTap: () => context.push(AppRoutes.duaDetail, extra: dua),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Could not load duas.')),
      ),
    );
  }
}
