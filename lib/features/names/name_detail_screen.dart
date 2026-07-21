import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/favorite_names_repository.dart';
import '../../data/names_repository.dart';

class NameDetailScreen extends ConsumerWidget {
  const NameDetailScreen({super.key, required this.name});

  final NameEntry name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteNamesProvider);
    final favoritesNotifier = ref.read(favoriteNamesProvider.notifier);
    final isFavorite = favorites.contains(name.id);

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(name.transliteration),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? colorScheme.secondary : null,
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            onPressed: () => favoritesNotifier.toggle(name.id),
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
                name.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: textTheme.displaySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name.transliteration,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name.meaning,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    name.explanation,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(height: 1.5),
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
