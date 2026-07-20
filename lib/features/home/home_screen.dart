import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';

/// The Home tab: a grid of cards linking to every feature. Cards for
/// sections that also live on the bottom nav (Tasbeeh, Duas, Prayer Times)
/// switch tabs; everything else pushes a full-screen route, same as "More".
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _items = [
    _DashboardItem(
      label: 'Tasbeeh Counter',
      icon: Icons.fingerprint_outlined,
      route: AppRoutes.tasbeeh,
      isTab: true,
    ),
    _DashboardItem(
      label: 'Duas',
      icon: Icons.menu_book_outlined,
      route: AppRoutes.duas,
      isTab: true,
    ),
    _DashboardItem(
      label: 'Morning & Evening Adhkar',
      icon: Icons.spa_outlined,
      route: AppRoutes.adhkar,
    ),
    _DashboardItem(
      label: 'Namaz Tracker',
      icon: Icons.checklist_outlined,
      route: AppRoutes.namazTracker,
    ),
    _DashboardItem(
      label: 'Prayer Times',
      icon: Icons.access_time_outlined,
      route: AppRoutes.prayerTimes,
      isTab: true,
    ),
    _DashboardItem(
      label: 'Qibla',
      icon: Icons.explore_outlined,
      route: AppRoutes.qibla,
    ),
    _DashboardItem(
      label: 'Hadith',
      icon: Icons.auto_stories_outlined,
      route: AppRoutes.hadith,
    ),
    _DashboardItem(
      label: '99 Names of Allah',
      icon: Icons.star_border,
      route: AppRoutes.names,
    ),
    _DashboardItem(
      label: 'Favorites',
      icon: Icons.favorite_border,
      route: AppRoutes.favorites,
    ),
    _DashboardItem(
      label: 'Progress',
      icon: Icons.bar_chart_outlined,
      route: AppRoutes.progress,
    ),
    _DashboardItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      route: AppRoutes.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zikr')),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) => _DashboardCard(item: _items[index]),
        ),
      ),
    );
  }
}

class _DashboardItem {
  const _DashboardItem({
    required this.label,
    required this.icon,
    required this.route,
    this.isTab = false,
  });

  final String label;
  final IconData icon;
  final String route;

  /// True for sections that are also a bottom-nav tab, so tapping the
  /// card switches tabs (`go`) instead of stacking a new screen (`push`).
  final bool isTab;
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({required this.item});

  final _DashboardItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            item.isTab ? context.go(item.route) : context.push(item.route),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 32, color: colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
