
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
- Prayer times: `adhan` (free offline astronomical calculation, no paid API) —
  added in Phase 11. Device location via `geolocator`; reminder notifications via
  `flutter_local_notifications` + `timezone` (bundled IANA database). See Phase 11
  below.
- Qibla: `flutter_compass` (device magnetometer heading) + the same
  `geolocator`/cached-location infrastructure as Prayer Times, direction
  computed via adhan's own `Qibla` class — added in Phase 12, no paid API.

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
    widgets/     # shared reusable widgets: placeholder_screen.dart,
                 # city_search_delegate.dart (SearchDelegate<CityEntry?> over
                 # the bundled cities list), location_picker.dart
                 # (LocationPickerMixin: useDeviceLocation/chooseCity/
                 # showChangeLocationSheet, shared by Prayer Times + Qibla,
                 # both against the one prayerLocationProvider; plus the
                 # LocationPickerPrompt empty-state and CachedLocationCard
                 # widgets)
  data/          # shared data sources: hive_boxes.dart (box name constants),
                 # dhikr_repository.dart (DhikrEntry model + JSON asset loader +
                 # dhikrLibraryProvider), custom_dhikr_repository.dart
                 # (CustomDhikrEntry model + Hive-backed CRUD + customDhikrProvider),
                 # duas_repository.dart (DuaEntry model + JSON asset loader +
                 # duasProvider + duaCategoriesOf()), favorite_duas_repository.dart
                 # (Hive-backed favorite-id set + favoriteDuasProvider),
                 # adhkar_repository.dart (AdhkarEntry model + JSON asset loader +
                 # adhkarProvider), adhkar_progress_repository.dart (per-day
                 # per-period completed-id sets + morning/eveningAdhkarProgressProvider),
                 # hadith_repository.dart (HadithEntry model + JSON asset loader +
                 # hadithProvider + hadithCategoriesOf()), favorite_hadith_repository.dart
                 # (Hive-backed favorite-id set + favoriteHadithProvider),
                 # names_repository.dart (NameEntry model + JSON asset loader +
                 # namesProvider), favorite_names_repository.dart (Hive-backed
                 # favorite-id set + favoriteNamesProvider), namaz_tracker_repository.dart
                 # (namazPrayers list + per-day completed-prayer sets +
                 # namazTrackerProvider + DayCompletion/NamazStats aggregation +
                 # namazStatsProvider), cities_repository.dart (CityEntry model +
                 # JSON asset loader + citiesProvider — bundled manual-location
                 # fallback list), prayer_location_repository.dart (CachedLocation
                 # model + Hive-backed device/manual location cache +
                 # prayerLocationProvider), prayer_settings_repository.dart
                 # (PrayerSettings model: calculation method/madhab/notifications
                 # toggle + Hive-backed prayerSettingsProvider + method/madhab
                 # label maps), prayer_times_repository.dart (pure adhan
                 # calculation + DailyPrayerTimes model + todayPrayerTimesProvider),
                 # prayer_notifications_repository.dart (flutter_local_notifications
                 # setup + today's-remaining-prayers scheduling)
  features/      # one folder per feature:
                 # home (dashboard grid), tasbeeh (full feature: Hive-backed
                 # counter, goal/dhikr selection, sound/vibration), dhikr_library
                 # (list + detail screens for the bundled dhikr content),
                 # custom_dhikr (add/edit/delete the user's own dhikr), duas
                 # (data-driven category list, category → dua list, detail with
                 # favorite toggle, cross-category search), adhkar (Morning/Evening
                 # hub with today's progress, checklist screen with checkboxes),
                 # hadith (same data-driven category/search/favorite shape as
                 # duas), names (flat 99-entry list, no categories — search +
                 # favorite + detail), namaz_tracker (Daily/Weekly/Monthly tabs,
                 # tap-to-toggle prayer cards, streak banner), prayer_times
                 # (today's 6 prayer/sunrise times, location card with device/
                 # manual-city switch, next-prayer banner, settings sub-screen for
                 # method/madhab/notifications), qibla (rotating-arrow compass
                 # over the device heading, "facing Qibla" state, bearing +
                 # distance to the Kaaba — shares its location UI with Prayer
                 # Times via core/widgets/location_picker.dart), more (nav hub),
                 # favorites, progress, settings — the rest still screen-only
                 # placeholders
  app.dart       # MaterialApp.router root widget
  main.dart      # entry point: Hive.initFlutter(), opens the Hive boxes, ProviderScope
assets/
  data/          # bundled JSON: dhikr.json (11 entries — see "Dhikr Library" below),
                 # duas.json (12 categories — see "Daily Duas" below), adhkar.json
                 # (13 morning + 14 evening entries — see "Morning & Evening Adhkar"
                 # below), hadith.json (10 categories — see "Hadith" below),
                 # names.json (all 99 — see "99 Names of Allah" below),
                 # cities.json (127 major world cities — see "Prayer Times" below).
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

### Daily Duas (Phase 6)
`assets/data/duas.json` bundles 12 categories (Sleep, Wake Up, Travel, Eating, Home,
Mosque, Rain, Parents, Forgiveness, Sickness, Marriage, Istikhara), one dua each to
start. **Data-driven, not an enum**: the category list shown in the UI is derived
from whichever `category` values are present in the JSON (`duaCategoriesOf()`), so
adding a 13th category — or a 2nd dua in an existing one — needs only a JSON edit,
no code change. Favoriting persists dua ids in the `favorite_duas` Hive box
(`favoriteDuasProvider`), following the same synchronous-notifier pattern as
Phase 5. Search is a `SearchDelegate` over the already-loaded dua list (category,
transliteration, translation), no separate index needed at this size.
**Content sourcing**: same standard as Phase 4 — every entry traces to the Quran or
one of Sahih Bukhari, Sahih Muslim, Sunan Abu Dawood, Jami' at-Tirmidhi, Sunan
an-Nasa'i, Sunan Ibn Majah, or Musnad Ahmad, and every citation was verified against
sunnah.com/quran.com before being added, not recalled from memory alone; you
confirmed the drafted list before it was finalized.

### Morning & Evening Adhkar (Phase 7)
`assets/data/adhkar.json` bundles the core Hisnul Muslim morning/evening routine:
13 morning entries and 14 evening entries (mostly the same content — a few, like
"Asbahna.../Amsayna...", flip wording by time of day — plus the last two verses of
Al-Baqarah, evening-only per its hadith). Each entry carries a `repeat` count (e.g.
×3, ×7, ×100) shown as a chip. The Adhkar hub (More/Home → Adhkar) shows a
"completed of total" card per period; tapping opens a checklist screen where each
item is a tappable card with a checkbox — checking one persists immediately.
**Storage** (`adhkar_progress` Hive box, `adhkarProgressKey(period, date)` →
`List<String>` of completed ids): keyed by day so the checklist naturally resets
each morning/evening, and the per-day history is already in the shape a future
Progress feature needs (streaks, completion %) — `adhkarProgressKey()` is exported
for that reuse. Same synchronous never-await-the-write notifier pattern as
Phases 5–6. **Content sourcing**: same standard as Phases 4/6, confirmed with you
before finalizing — you asked for two additions (the tahlil/istighfar ×100 duo and
the last two verses of Al-Baqarah) beyond the initial draft, both verified against
sunnah.com/quran.com before being added.

### Hadith (Phase 8)
`assets/data/hadith.json` bundles 10 categories (Faith, Prayer, Charity, Fasting,
Good Character, Knowledge, Mercy & Kindness, Intentions, Patience, Parents &
Family), one hadith each to start. Same data-driven shape as Daily Duas —
category list derived from whichever `category` values are present
(`hadithCategoriesOf()`), category browsing, cross-category `SearchDelegate`, and
Hive-backed favoriting (`favorite_hadith` box, `favoriteHadithProvider`) all mirror
Phase 6's pattern rather than introducing a new one. Each entry carries `book`
(the collection name), `authenticityNote` (grading, e.g. "Sahih (Authentic)"), and
`reference` (hadith number) as separate fields, shown on the detail screen.
**Content sourcing**: same standard as Phases 4/6/7 — every entry is Sahih, from
Sahih al-Bukhari, Sahih Muslim, or Jami' at-Tirmidhi, verified against sunnah.com
before being added; you confirmed the drafted list before it was finalized.

### 99 Names of Allah (Phase 9)
`assets/data/names.json` bundles all 99 names (not a subset), in the traditional
order, each with Arabic, transliteration, a short meaning, and a 1-sentence
explanation. No categories — a flat list with search and favoriting
(`favorite_names` box, `favoriteNamesProvider`), same shape as Duas/Hadith minus
the category layer. Two pairs of names look identical when romanized but are
distinct in Arabic and position: "Al-Waliyy" (#55, الولي, the Protecting Friend)
vs. "Al-Wali" (#77, الوالي, the Governor), and "Al-Majeed" (#48, glory) vs.
"Al-Maajid" (#65, nobility) — kept as separate entries with distinguishing
transliteration spelling, matching how reference sources disambiguate them.
**Content sourcing**: different shape from Phases 4/6/7/8 since this is the one
complete, universally-agreed list rather than a curated subset — confirmed with
you upfront that the standard published enumeration would be used (not
individually hadith-cited per name, which isn't how this content is normally
sourced), then the ordering was cross-verified across two independent published
enumerations (matching name-for-name from #64 on) before compiling the file,
rather than relying on recall alone for a list this long. Core reference for the
concept itself: Quran 7:180; Sahih al-Bukhari 2736; Sahih Muslim 2677.

### Namaz Tracker (Phase 10)
No Islamic content in this phase — a functional tracker, so no sourcing gate
applies. `namaz_tracker` Hive box (`namazTrackerKey(date)` → `List<String>` of
completed prayer names for that day, mirroring the `adhkar_progress` per-day-key
shape from Phase 7) backs `NamazTrackerNotifier`/`namazTrackerProvider` for
today's Fajr/Dhuhr/Asr/Maghrib/Isha completion — same synchronous
never-await-the-write pattern as every other Hive-backed notifier. The screen
(`NamazTrackerScreen`) is a 3-tab `DefaultTabController`: **Daily** (streak
banner + 5 tappable prayer cards), **Weekly** (read-only last-7-days progress
bars), **Monthly** (read-only calendar grid for the current month, each day
shaded by completion fraction, today outlined). `DayCompletion` (date +
completed set) and `NamazStats` (today/week/month/currentStreak) are pure
helpers in `namaz_tracker_repository.dart` that read the Hive box directly,
exposed via `namazStatsProvider`; `currentStreak` counts consecutive
fully-complete days backward from today, only counting today itself once it's
fully complete (so an unfinished today doesn't zero out a real streak).

### Prayer Times (Phase 11)
No Islamic content in this phase either — a calculation/notification feature, so
no sourcing gate applies. Adds 4 packages: `adhan` (pure offline astronomical
calculation — coordinates + date in, prayer times out, no network of any kind),
`geolocator` (device GPS), `flutter_local_notifications` + `timezone` (local
reminder scheduling; the timezone package's bundled IANA database is compiled
into the app, not fetched).

**Location**: device GPS (with the standard permission flow: check → request →
handle denied/deniedForever) or a manual pick from `assets/data/cities.json` (127
bundled major cities — name, country, lat/lon, IANA timezone id). Either way the
result is cached as a `CachedLocation` in the `prayer_settings` Hive box under the
`location` key, so prayer times still compute fully offline on every subsequent
launch without needing a fresh GPS fix. The Prayer Times screen shows an empty
state with "Use My Location" / "Choose a City" buttons until a location exists,
then the times screen with a "Change" action.

**Calculation**: `computePrayerTimes()` always calls `PrayerTimes.utc(...)` (raw
UTC output) rather than adhan's default local-time conversion, then converts to
display time itself — `.toLocal()` for a device-sourced location (correct because
the device's own system timezone already matches wherever its GPS says it is), or
`tz.TZDateTime.from(utc, tz.getLocation(city.timezone))` for a manually-picked
city (so a picked city displays in *its own* local time, not the device's — no
separate device-timezone-detection package needed, since the device case never
touches the `timezone` package at all). Calculation method (11 of adhan's presets,
`other` excluded as meaningless on its own) and Madhab (Shafi/Hanafi, affecting
only Asr) are user-selectable on a dedicated Prayer Settings screen
(`PrayerSettingsScreen`, `/prayer-settings`) and persisted in the same
`prayer_settings` box (`method`/`madhab` keys), read back via
`CalculationMethod.values`/`Madhab.values` `.name` round-tripping.

**Notifications**: deliberately "today's remaining prayers only", not a recurring
schedule — prayer times shift by a few minutes daily, so `scheduleTodayPrayerNotifications()`
cancels everything and re-schedules from scratch. It's called via `ref.listen` on
the Prayer Times screen whenever `todayPrayerTimesProvider` changes (new location,
changed method/madhab) or the notifications toggle flips, which in practice means
"every time the user opens the tab" — acceptable for a typical daily-open usage
pattern without needing a background task scheduler (WorkManager, etc., which
would add real complexity for comparatively little benefit here). Enabling the
toggle requests Android's `POST_NOTIFICATIONS` and exact-alarm permissions;
scheduling failures (e.g. exact-alarm permission missing) are caught per-prayer
so one failure doesn't drop the rest of the day's reminders.

**Android setup**: `flutter_local_notifications` 22.x requires core library
desugaring — added `isCoreLibraryDesugaringEnabled = true` plus the
`desugar_jdk_libs` dependency to `android/app/build.gradle.kts`. Manifest gained
`ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` (geolocator doesn't merge these
in automatically) and `POST_NOTIFICATIONS`/`SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM`.

### Qibla (Phase 12)
No Islamic content in this phase either — a calculation/sensor feature, so no
sourcing gate applies. Reuses Phase 11's location infrastructure wholesale
rather than duplicating it: `QiblaScreen` reads the same `prayerLocationProvider`
(device GPS or a manually-picked city), so a location picked on either screen
carries over to the other. That reuse prompted extracting the location-picking
UI out of `features/prayer_times/` into shared `core/widgets/` — see the Folder
structure entry above — rather than copy-pasting an "empty state + change
location sheet" a second time.

**Bearing**: `Qibla(Coordinates(lat, lon)).direction` (from the `adhan`
package — the same library already in use for prayer times, which happens to
ship its own qibla-bearing calculation) gives degrees clockwise from true
north. Distance to the Kaaba uses `Geolocator.distanceBetween()` against
`Qibla.MAKKAH`.

**Compass UI**: `flutter_compass` streams the device's magnetometer heading
(0-360°, 0 = north). Deliberately *not* a rotating N/E/S/W dial — a dial that
doesn't itself rotate with the device wouldn't correspond to real compass
directions, and one that does needs cardinal labels to stay correct, adding
complexity for a feature whose whole point is "point your phone until the
arrow lines up." Instead: a fixed tick-mark ring + fixed top marker
(representing wherever the phone's top is physically pointing), and a single
arrow rotated by `(qiblaBearing - heading)` so it always points at the Kaaba
in real-world space as the device turns — when the arrow points straight up
(within 5°), the app shows a "Facing the Qibla" state (accent color + label).
No magnetic-declination correction is applied (heading is treated as
approximately true north) — reasonable for "simple, clear compass UI" scope,
not a survey-grade instrument.

**Testing gotcha**: `FlutterCompass.events` never emits under `flutter test`
(no real magnetometer), so the compass sits in its "waiting for a reading"
state — an indeterminate `CircularProgressIndicator` — for the rest of the
test. `pumpAndSettle()` waits for all animations to finish, which never
happens with an indeterminate spinner, so any Qibla test with a location
already set must use bounded `tester.pump()` calls instead once past the
initial navigation. See `test/qibla/qibla_test_helpers.dart` and the new
`mockCompassChannel()` in `test/support/mock_platform_channels.dart` (same
"stub the channel so `flutter_compass`'s EventChannel doesn't hang forever
waiting for a platform reply" reasoning as `mockSystemChannels()`).

## Coding conventions
- Small, focused widgets. Extract reusable widgets into `core/widgets/`.
- Comment non-obvious logic, especially Islamic content structures and calculation
  logic (prayer times, qibla).
- No excessive comments on self-explanatory code.
- Keep each phase's code compiling and runnable before moving on.

## Testing conventions (found across Phases 3–6, keep following these)
- **One `testWidgets` per file.** Multiple tests in one file were observed to hang
  or time out unpredictably in this sandbox's `flutter test` runner (each file is
  its own process, so this buys reliable isolation at the cost of some startup
  overhead). See `test/tasbeeh/tasbeeh_test_helpers.dart` and
  `test/custom_dhikr/custom_dhikr_test_helpers.dart` for the pattern.
- **Reset `appRouter` at the start of every pump.** `appRouter` (in
  `lib/core/router/app_router.dart`) is a module-level singleton, so its location
  survives across sequential tests in the same file even with one-test-per-file;
  call `appRouter.go(AppRoutes.<somewhere>)` before `pumpWidget` in every shared
  test helper's pump function.
- **Never `await` a Hive `Box` write inside a widget test.** Whether it's app code
  awaited from a widget callback, or a raw `Box.put`/`.add` called directly in a
  test body — both hang forever inside `testWidgets`' FakeAsync zone, because the
  real disk-flush Future never resolves there. Keep Hive-backed notifiers
  synchronous (see the Phase 5 note above), and when seeding a box directly in a
  test, don't `await` it either.
- **`Hive.initFlutter()` doesn't work under `flutter test`** (no path_provider
  platform channel). Use `test/support/hive_test_setup.dart`'s `initTestHive()`
  (plain `Hive.init()` against a temp directory) instead.
- **Mock `SystemChannels.platform`** before any test that exercises
  `SystemSound.play`/`HapticFeedback` (i.e. anything that taps the Tasbeeh ring) —
  see `test/support/mock_platform_channels.dart`. Without it the call hangs the
  same way an awaited Hive write does.
- **Call `tz.initializeTimeZones()`** (from `package:timezone/data/latest.dart`)
  in `setUpAll` before any test that renders prayer times for a manually-picked
  city — `main.dart` normally does this at startup, but tests build `ZikrApp()`
  directly without ever running `main()`. See
  `test/prayer_times/prayer_times_test_helpers.dart`. Device-location prayer
  times don't need it (they never touch the `timezone` package), but it's
  harmless to always include once a test file touches Prayer Times at all.
- Any test file that visits a screen touching a Hive box must open every box
  (via `initTestHive`/`disposeTestHive`), even boxes unrelated to what the test
  is checking — e.g. `test/home_dashboard_test.dart` needs the full set once its
  "switch to Prayer Times tab" case exists, not just the boxes Home itself uses.
- **Mock the compass EventChannel** (`mockCompassChannel()` in
  `test/support/mock_platform_channels.dart`) before any test that renders the
  Qibla screen — same hang-forever problem as `SystemChannels.platform`. And
  because the mocked channel never actually delivers a heading, any such test
  must use bounded `tester.pump()` calls instead of `pumpAndSettle()` once a
  location is set — the compass's indeterminate loading spinner never
  "settles". See `test/qibla/qibla_test_helpers.dart`.

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
