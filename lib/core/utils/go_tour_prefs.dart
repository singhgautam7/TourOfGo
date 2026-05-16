/// SharedPreferences key constants for Tour of Go.
class GoTourPrefs {
  GoTourPrefs._();

  static const contentJson = 'go_tour_content_json';
  static const lastFetchTime = 'go_tour_last_fetch_ms';
  static const onboarded = 'go_tour_onboarded';
  static const currentChapterKey = 'go_tour_chapter';
  static const currentLessonIdx = 'go_tour_lesson_idx';
  static const completedJson = 'go_tour_completed';
  static const themeMode = 'go_tour_theme';
  static const fontSize = 'go_tour_font_size';
  static const wrapLines = 'go_tour_wrap_lines';
  static const recentSearches = 'go_tour_recent_searches';

  // Go by Example
  static const gbeIndexJson = 'gbe_index_json';
  static const gbeExamplePrefix = 'gbe_example_v3_'; // + slug
  static const gbeIndexLoaded = 'gbe_index_loaded';
  static const gbeCompleted = 'gbe_completed_json';
}
