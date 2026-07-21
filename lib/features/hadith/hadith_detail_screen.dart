import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/favorite_hadith_repository.dart';
import '../../data/hadith_repository.dart';

class HadithDetailScreen extends ConsumerWidget {
  const HadithDetailScreen({super.key, required this.hadith});

  final HadithEntry hadith;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteHadithProvider);
    final favoritesNotifier = ref.read(favoriteHadithProvider.notifier);
    final isFavorite = favorites.contains(hadith.id);

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(hadith.category),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? colorScheme.secondary : null,
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () => favoritesNotifier.toggle(hadith.id),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                hadith.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: textTheme.headlineMedium?.copyWith(height: 1.8),
              ),
              const SizedBox(height: 20),
              Text(
                hadith.translation,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${hadith.book}, ${hadith.reference}',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              hadith.authenticityNote,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
