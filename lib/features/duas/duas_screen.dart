import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/duas_repository.dart';
import 'dua_search_delegate.dart';

/// Category icons are a display nicety, not a data requirement — a category
/// with no entry here still renders fine with the fallback icon, so new
/// categories in duas.json need no code change to show up.
const Map<String, IconData> _categoryIcons = {
  'Sleep': Icons.bedtime_outlined,
  'Wake Up': Icons.wb_sunny_outlined,
  'Travel': Icons.flight_outlined,
  'Eating': Icons.restaurant_outlined,
  'Home': Icons.home_outlined,
  'Mosque': Icons.mosque_outlined,
  'Rain': Icons.water_drop_outlined,
  'Parents': Icons.family_restroom_outlined,
  'Forgiveness': Icons.self_improvement_outlined,
  'Sickness': Icons.healing_outlined,
  'Marriage': Icons.favorite_outline,
  'Istikhara': Icons.auto_awesome_outlined,
};
const _fallbackCategoryIcon = Icons.menu_book_outlined;

class DuasScreen extends ConsumerWidget {
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duas = ref.watch(duasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duas'),
        actions: [
          duas.when(
            data: (allDuas) => IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search duas',
              onPressed: () async {
                final selected = await showSearch<DuaEntry?>(
                  context: context,
                  delegate: DuaSearchDelegate(allDuas),
                );
                if (selected != null && context.mounted) {
                  context.push(AppRoutes.duaDetail, extra: selected);
                }
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: duas.when(
        data: (allDuas) {
          final categories = duaCategoriesOf(allDuas);
          return ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = categories[index];
              final count = allDuas
                  .where((dua) => dua.category == category)
                  .length;
              return ListTile(
                leading: Icon(
                  _categoryIcons[category] ?? _fallbackCategoryIcon,
                ),
                title: Text(category),
                subtitle: Text('$count ${count == 1 ? 'dua' : 'duas'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push(AppRoutes.duaCategory, extra: category),
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
