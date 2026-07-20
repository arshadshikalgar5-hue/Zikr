
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
- State management: Riverpod (or Provider if simpler — pick one and stay consistent)
- Clean architecture: separate `data/`, `domain/`, `presentation/` (or feature-first
  folders — decide in Phase 1 and document here)
- Prayer times: free offline calculation package (e.g. `adhan` dart port), no paid API
- Qibla: device compass + geolocation, no paid API

## Build / run commands
- `flutter pub get` — install dependencies
- `flutter run` — run in debug
- `flutter build apk --release` — build release APK
- `flutter analyze` — lint check before finishing any phase
- `flutter test` — run tests if/when added

## Folder structure (fill in after Phase 1 decision, then keep updated)
```
lib/
  core/          # theme, constants, utils, shared widgets
  data/          # models, local data sources (Hive boxes, JSON asset loaders)
  features/      # one folder per feature: tasbeeh, duas, adhkar, hadith, names,
                 # namaz_tracker, prayer_times, qibla, favorites, progress, settings
  app.dart
  main.dart
assets/
  data/          # bundled JSON: duas.json, hadith.json, names.json, adhkar.json
  images/
  fonts/
```

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
