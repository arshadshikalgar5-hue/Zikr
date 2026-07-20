
# Project: [Zikr] — Free Islamic Companion App

## What this project is
A 100% free, offline-first Islamic Android app (Sadqah Jariyah project). No ads, no
subscriptions, no paid APIs, no backend server, no Firebase, no cloud database.
Islamic content is bundled inside the app and only changes when a new signed APK is
released. This file is permanent context — read it at the start of every session.

## Non-negotiable rules (never violate these)
- No backend server. No cloud database. No Firebase.
- No paid APIs of any kind.
- Islamic content (Duas, Hadith, Adhkar, 99 Names) is stored as local bundled data
  (JSON assets), never fetched from the internet at runtime.
- Internet is used ONLY for: checking version.json on GitHub, downloading the APK.
  Nothing else requires internet.
- Updates are notify + manual download only. Never auto-install.
- App must work fully offline once installed (except the optional update check).

## Tech stack
- Flutter (latest stable), Dart
- Local storage: Hive for user data (tasbeeh counts, favorites, custom dhikr, prayer
  tracker logs, settings). Bundled JSON assets for static Islamic content.
- State management: **Riverpod** (`flutter_riverpod`) — decided in Phase 1. Chosen
  over Provider for compile-time safety, easier testing without BuildContext, and
  no dependence on widget-tree position for reading state.
- Routing: **go_router**, using `StatefulShellRoute.indexedStack` for the bottom-nav
  shell so each tab keeps its own navigation stack.
- Architecture: **feature-first** (decided in Phase 1, see folder structure below).
  `lib/data/` holds shared/global data sources (Hive box setup, JSON asset loaders);
  each feature folder is presentation-only for now. Per-feature `data/`/`domain/`
  split will be introduced only if/when a feature's logic grows complex enough to
  need it — not created preemptively.
- Prayer times: free offline calculation package (e.g. `adhan` dart port), no paid API
  — not yet added, will be introduced in the prayer times phase.
- Qibla: device compass + geolocation, no paid API — not yet added, will be
  introduced in the qibla phase.

## Build / run commands
- `flutter pub get` — install dependencies
- `flutter run` — run in debug
- `flutter build apk --release` — build release APK
- `flutter analyze` — lint check before finishing any phase
- `flutter test` — run tests if/when added

## Folder structure (set in Phase 1, keep updated as it evolves)
```
lib/
  core/
    constants/   # app_routes.dart — centralised route path strings
    router/      # app_router.dart (GoRouter config), navigation_shell.dart (bottom nav)
    theme/       # app_colors.dart, app_theme.dart (light/dark ThemeData)
    widgets/     # shared reusable widgets, e.g. placeholder_screen.dart
  data/          # (empty so far) models, local data sources (Hive boxes, JSON
                 # asset loaders) — to be filled in as features need persistence
  features/      # one folder per feature, screen-only for now:
                 # home, prayer_times, duas, tasbeeh, more, adhkar, hadith, names,
                 # namaz_tracker, qibla, favorites, progress, settings
                 # ("home" is the dashboard tab; "more" is the nav hub screen
                 # that links to the features not on the bottom bar)
  app.dart       # MaterialApp.router root widget
  main.dart      # entry point: Hive.initFlutter() + ProviderScope
assets/
  data/          # bundled JSON: duas.json, hadith.json, names.json, adhkar.json (empty so far)
  images/        # (empty so far)
  fonts/         # (empty so far) — for a locally-bundled Arabic-appropriate typeface later;
                 # deliberately not using google_fonts package, since its default
                 # mode fetches font files over the network at runtime
```

### Navigation shell (Phase 1)
Bottom nav has 5 destinations: **Home, Prayer Times, Duas, Tasbeeh, More**. "More" is
a plain list screen linking to the remaining 8 features (Adhkar, Hadith, 99 Names,
Namaz Tracker, Qibla, Favorites, Progress, Settings), pushed as full-screen routes
outside the tab shell so the back button behaves normally. All screens are currently
`PlaceholderScreen` — no feature logic yet.

### Theme (Phase 1)
Material 3, `ColorScheme.fromSeed` with a deep emerald green seed and a warm gold
secondary accent — no literal religious iconography. Light mode uses a warm
off-white background; dark mode uses a deep charcoal-green. Typography is the
Material 3 default type ramp with restrained weight/spacing tweaks — no custom or
network-fetched fonts yet.

## Coding conventions
- Small, focused widgets. Extract reusable widgets into `core/widgets/`.
- Comment non-obvious logic, especially Islamic content structures and calculation
  logic (prayer times, qibla).
- No excessive comments on self-explanatory code.
- Keep each phase's code compiling and runnable before moving on.

## Update system (GitHub-based, no Play Store)
- A `version.json` file hosted on a public GitHub repo (or Release) contains the
  latest version number + APK download URL.
- App checks this file on startup (or on demand), compares with installed version.
- If newer, show "Update Available" → user taps → APK downloads → Android installer
  opens. Never auto-install.

## Development process — IMPORTANT
- Work strictly in phases (see phase prompts document).
- Do NOT start the next phase until I explicitly approve the current one.
- At the start of a phase: briefly explain what you're about to build.
- At the end of a phase: summarize what was completed, list any decisions you made,
  and state what the next phase will cover.
- If something in this file conflicts with a phase instruction, this file wins.
- Keep responses focused — I'm running on limited Claude Code credits, so avoid
  unnecessary exploration or rewriting unrelated code.

## Content sourcing note
All Hadith/Dua/Adhkar/Names content must come from authentic, verifiable sources
(e.g.  Sahih Bukhari/Muslim references). If you are asked to add
Islamic text content, ask me to confirm the source if it isn't provided, rather than
generating it from memory.
