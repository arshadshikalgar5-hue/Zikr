import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _items = [
    _MoreItem('Adhkar', Icons.spa_outlined, AppRoutes.adhkar),
    _MoreItem(
      'Dhikr Library',
      Icons.library_books_outlined,
      AppRoutes.dhikrLibrary,
    ),
    _MoreItem('Hadith', Icons.auto_stories_outlined, AppRoutes.hadith),
    _MoreItem('99 Names', Icons.star_border, AppRoutes.names),
    _MoreItem('Namaz Tracker', Icons.checklist_outlined, AppRoutes.namazTracker),
    _MoreItem('Qibla', Icons.explore_outlined, AppRoutes.qibla),
    _MoreItem('Favorites', Icons.favorite_border, AppRoutes.favorites),
    _MoreItem('Progress', Icons.bar_chart_outlined, AppRoutes.progress),
    _MoreItem('Settings', Icons.settings_outlined, AppRoutes.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            leading: Icon(item.icon),
            title: Text(item.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(item.route),
          );
        },
      ),
    );
  }
}

class _MoreItem {
  const _MoreItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
