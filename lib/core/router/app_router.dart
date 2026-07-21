import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/custom_dhikr_repository.dart';
import '../../data/dhikr_repository.dart';
import '../../data/duas_repository.dart';
import '../../data/hadith_repository.dart';
import '../../data/names_repository.dart';
import '../../features/adhkar/adhkar_checklist_screen.dart';
import '../../features/adhkar/adhkar_screen.dart';
import '../../features/custom_dhikr/custom_dhikr_form_screen.dart';
import '../../features/custom_dhikr/custom_dhikr_screen.dart';
import '../../features/dhikr_library/dhikr_detail_screen.dart';
import '../../features/dhikr_library/dhikr_library_screen.dart';
import '../../features/duas/dua_category_screen.dart';
import '../../features/duas/dua_detail_screen.dart';
import '../../features/duas/duas_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/hadith/hadith_category_screen.dart';
import '../../features/hadith/hadith_detail_screen.dart';
import '../../features/hadith/hadith_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/more/more_screen.dart';
import '../../features/namaz_tracker/namaz_tracker_screen.dart';
import '../../features/names/name_detail_screen.dart';
import '../../features/names/names_screen.dart';
import '../../features/prayer_times/prayer_times_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/qibla/qibla_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tasbeeh/tasbeeh_screen.dart';
import '../constants/app_routes.dart';
import 'navigation_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// App-wide route table. The 5 bottom-nav sections live inside a
/// [StatefulShellRoute] so each keeps its own back stack; everything
/// reached from "More" is a plain full-screen route pushed on top.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          NavigationShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.prayerTimes,
              builder: (context, state) => const PrayerTimesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.duas,
              builder: (context, state) => const DuasScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.tasbeeh,
              builder: (context, state) => const TasbeehScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.more,
              builder: (context, state) => const MoreScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.adhkar,
      builder: (context, state) => const AdhkarScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.hadith,
      builder: (context, state) => const HadithScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.names,
      builder: (context, state) => const NamesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.namazTracker,
      builder: (context, state) => const NamazTrackerScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.qibla,
      builder: (context, state) => const QiblaScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.favorites,
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.progress,
      builder: (context, state) => const ProgressScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.dhikrLibrary,
      builder: (context, state) => const DhikrLibraryScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.dhikrDetail,
      builder: (context, state) =>
          DhikrDetailScreen(entry: state.extra! as DhikrEntry),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.customDhikr,
      builder: (context, state) => const CustomDhikrScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.customDhikrForm,
      builder: (context, state) =>
          CustomDhikrFormScreen(entry: state.extra as CustomDhikrEntry?),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.duaCategory,
      builder: (context, state) =>
          DuaCategoryScreen(category: state.extra! as String),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.duaDetail,
      builder: (context, state) => DuaDetailScreen(dua: state.extra! as DuaEntry),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.adhkarChecklist,
      builder: (context, state) =>
          AdhkarChecklistScreen(period: state.extra! as String),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.hadithCategory,
      builder: (context, state) =>
          HadithCategoryScreen(category: state.extra! as String),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.hadithDetail,
      builder: (context, state) =>
          HadithDetailScreen(hadith: state.extra! as HadithEntry),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: AppRoutes.nameDetail,
      builder: (context, state) =>
          NameDetailScreen(name: state.extra! as NameEntry),
    ),
  ],
);
