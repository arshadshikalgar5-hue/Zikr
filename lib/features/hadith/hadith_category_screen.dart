import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/favorite_hadith_repository.dart';
import '../../data/hadith_repository.dart';

class HadithCategoryScreen extends ConsumerWidget {
  const HadithCategoryScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadith = ref.watch(hadithProvider);
    final favorites = ref.watch(favoriteHadithProvider);
    final favoritesNotifier = ref.read(favoriteHadithProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: hadith.when(
        data: (allHadith) {
          final entries = allHadith
              .where((entry) => entry.category == category)
              .toList();
          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isFavorite = favorites.contains(entry.id);
              return ListTile(
                title: Text(
                  entry.translation,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${entry.book}, ${entry.reference}'),
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
                  onPressed: () => favoritesNotifier.toggle(entry.id),
                ),
                onTap: () =>
                    context.push(AppRoutes.hadithDetail, extra: entry),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Could not load hadith.')),
      ),
    );
  }
}
