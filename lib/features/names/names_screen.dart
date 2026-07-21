import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/favorite_names_repository.dart';
import '../../data/names_repository.dart';
import 'name_search_delegate.dart';

class NamesScreen extends ConsumerWidget {
  const NamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(namesProvider);
    final favorites = ref.watch(favoriteNamesProvider);
    final favoritesNotifier = ref.read(favoriteNamesProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('99 Names of Allah'),
        actions: [
          names.when(
            data: (allNames) => IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search names',
              onPressed: () async {
                final selected = await showSearch<NameEntry?>(
                  context: context,
                  delegate: NameSearchDelegate(allNames),
                );
                if (selected != null && context.mounted) {
                  context.push(AppRoutes.nameDetail, extra: selected);
                }
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: names.when(
        data: (allNames) => ListView.separated(
          itemCount: allNames.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final name = allNames[index];
            final isFavorite = favorites.contains(name.id);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                foregroundColor: colorScheme.primary,
                child: Text('${index + 1}'),
              ),
              title: Text(
                name.arabic,
                textDirection: TextDirection.rtl,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${name.transliteration} — ${name.meaning}'),
              trailing: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                color: isFavorite ? colorScheme.secondary : null,
                tooltip: isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                onPressed: () => favoritesNotifier.toggle(name.id),
              ),
              onTap: () => context.push(AppRoutes.nameDetail, extra: name),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('Could not load the 99 Names.')),
      ),
    );
  }
}
