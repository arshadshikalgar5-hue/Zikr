/// Centralised route paths so screens never hardcode a raw string.
abstract final class AppRoutes {
  // Bottom navigation branches.
  static const home = '/';
  static const prayerTimes = '/prayer-times';
  static const duas = '/duas';
  static const tasbeeh = '/tasbeeh';
  static const more = '/more';

  // Reached via the "More" screen.
  static const adhkar = '/adhkar';
  static const hadith = '/hadith';
  static const names = '/names';
  static const namazTracker = '/namaz-tracker';
  static const qibla = '/qibla';
  static const favorites = '/favorites';
  static const progress = '/progress';
  static const settings = '/settings';
  static const dhikrLibrary = '/dhikr-library';
  static const dhikrDetail = '/dhikr-detail';
  static const customDhikr = '/custom-dhikr';
  static const customDhikrForm = '/custom-dhikr-form';
  static const duaCategory = '/dua-category';
  static const duaDetail = '/dua-detail';
  static const adhkarChecklist = '/adhkar-checklist';
  static const hadithCategory = '/hadith-category';
  static const hadithDetail = '/hadith-detail';
  static const nameDetail = '/name-detail';
  static const prayerSettings = '/prayer-settings';
}
