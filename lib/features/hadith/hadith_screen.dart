import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/hadith_repository.dart';
import 'hadith_search_delegate.dart';

/// Category icons are a display nicety, not a data requirement — a category
/// with no entry here still renders fine with the fallback icon, so new
/// categories in hadith.json need no code change to show up.
const Map<String, IconData> _categoryIcons = {
  'Faith': Icons.star_outline,
  'Prayer': Icons.mosque_outlined,
  'Charity': Icons.volunteer_activism_outlined,
  'Fasting': Icons.no_food_outlined,
  'Good Character': Icons.emoji_people_outlined,
  'Knowledge': Icons.school_outlined,
  'Mercy & Kindness': Icons.favorite_outline,
  'Intentions': Icons.psychology_outlined,
  'Patience': Icons.hourglass_bottom_outlined,
  'Parents & Family': Icons.family_restroom_outlined,
};
const _fallbackCategoryIcon = Icons.auto_stories_outlined;

class HadithScreen extends ConsumerWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hadith = ref.watch(hadithProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith'),
        actions: [
          hadith.when(
            data: (allHadith) => IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Search hadith',
              onPressed: () async {
                final selected = await showSearch<HadithEntry?>(
                  context: context,
                  delegate: HadithSearchDelegate(allHadith),
                );
                if (selected != null && context.mounted) {
                  context.push(AppRoutes.hadithDetail, extra: selected);
                }
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: hadith.when(
        data: (allHadith) {
          final categories = hadithCategoriesOf(allHadith);
          return ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = categories[index];
              final count = allHadith
                  .where((entry) => entry.category == category)
                  .length;
              return ListTile(
                leading: Icon(
                  _categoryIcons[category] ?? _fallbackCategoryIcon,
                ),
                title: Text(category),
                subtitle: Text('$count hadith'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push(AppRoutes.hadithCategory, extra: category),
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
