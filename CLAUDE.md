
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
  data/          # shared data sources: hive_boxes.dart (box name constants),
                 # dhikr_repository.dart (DhikrEntry model + JSON asset loader +
                 # dhikrLibraryProvider), custom_dhikr_repository.dart
                 # (CustomDhikrEntry model + Hive-backed CRUD + customDhikrProvider)
  features/      # one folder per feature:
                 # home (dashboard grid), tasbeeh (full feature: Hive-backed
                 # counter, goal/dhikr selection, sound/vibration), dhikr_library
                 # (list + detail screens for the bundled dhikr content),
                 # custom_dhikr (add/edit/delete the user's own dhikr), more
                 # (nav hub), prayer_times, duas, adhkar, hadith, names,
                 # namaz_tracker, qibla, favorites, progress, settings — the
                 # rest still screen-only placeholders
  app.dart       # MaterialApp.router root widget
  main.dart      # entry point: Hive.initFlutter(), opens the tasbeeh box, ProviderScope
assets/
  data/          # bundled JSON: dhikr.json (11 entries — see "Dhikr Library" below).
                 # duas.json, hadith.json, names.json, adhkar.json still to come.
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

### Tasbeeh Counter (Phase 3)
Tap-anywhere-on-the-ring counter with a circular progress indicator, preset/custom
goals, preset/custom dhikr, pause/reset, and sound (`SystemSound.play`) / vibration
(`HapticFeedback`) toggles — no new packages needed for either. State lives in a
`Notifier<TasbeehState>` (`tasbeehProvider`) that auto-saves every field to the
`tasbeeh` Hive box on each change, so progress survives closing the app.

### Dhikr Library (Phase 4)
`assets/data/dhikr.json` bundles 11 short dhikr/dua entries (Arabic, transliteration,
meaning, reference), browsable via a list → detail screen (reachable from "More"),
and feeds the Tasbeeh dhikr dropdown directly (`dhikrLibraryProvider`) instead of a
hardcoded preset list. **Content sourcing**: scoped to Hisnul Muslim entries that
trace to the Quran or one of Sahih Bukhari, Sahih Muslim, Sunan Abu Dawood, Jami'
at-Tirmidhi, Sunan an-Nasa'i, Sunan Ibn Majah, or Musnad Ahmad, per your explicit
direction. Every hadith citation was verified against sunnah.com (not just recalled
from memory) before being added. Longer multi-clause supplications (Sayyid
al-Istighfar, "Asbahna wa asbahal mulku lillah", etc.) were deliberately excluded —
not a sourcing problem, just out of scope for this single-phrase tasbeeh-style
library; they belong to the separate Morning & Evening Adhkar feature later.

### Custom Dhikr (Phase 5)
Users can add their own dhikr/dua (required text, optional transliteration/meaning)
via a form screen reachable from "More" → "Custom Dhikr"; entries are editable, and
deletable via swipe-to-dismiss with a confirmation dialog. Stored in the
`custom_dhikr` Hive box (`CustomDhikrEntry`, `customDhikrProvider`) and merged into
the Tasbeeh dhikr dropdown alongside the bundled library. **Hive gotcha found this
phase**: `CustomDhikrNotifier`'s mutators are synchronous and never `await` the
`Box.put`/`Box.delete` call — matching `TasbeehNotifier`'s existing pattern. `Box`
updates its in-memory state synchronously and flushes to disk in the background;
awaiting that flush inside a widget callback hung every time under `flutter test`
(the real I/O future never resolves inside the test binding's FakeAsync zone).
Keep this pattern for any future Hive-backed notifier. Also: Hive int keys must
fit in `0 - 0xFFFFFFFF`, so entry ids are a small sequential counter, not a
timestamp.

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
