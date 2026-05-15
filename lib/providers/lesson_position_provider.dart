import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/tour_models.dart';
import '../core/utils/go_tour_prefs.dart';

part 'lesson_position_provider.g.dart';

typedef LessonPosition = ({String chapterKey, int lessonIndex});

@riverpod
class LessonPositionNotifier extends _$LessonPositionNotifier {
  @override
  LessonPosition build() {
    _loadFromPrefs();
    return (chapterKey: kChapterOrder.first, lessonIndex: 0);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final key =
        prefs.getString(GoTourPrefs.currentChapterKey) ?? kChapterOrder.first;
    final idx = int.tryParse(
          prefs.getString(GoTourPrefs.currentLessonIdx) ?? '0',
        ) ??
        0;
    state = (chapterKey: key, lessonIndex: idx);
  }

  Future<void> goTo(String chapterKey, int lessonIndex) async {
    state = (chapterKey: chapterKey, lessonIndex: lessonIndex);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(GoTourPrefs.currentChapterKey, chapterKey);
    await prefs.setString(GoTourPrefs.currentLessonIdx, lessonIndex.toString());
  }

  /// Advances to next lesson. Returns true if was the last in chapter.
  Future<bool> nextLesson(Map<String, ChapterData> content) async {
    final chapter = content[state.chapterKey];
    if (chapter == null) return false;
    final total = chapter.pages.length;
    if (state.lessonIndex >= total - 1) return true;
    await goTo(state.chapterKey, state.lessonIndex + 1);
    return false;
  }

  /// Goes back. If first lesson, stays.
  Future<void> prevLesson() async {
    if (state.lessonIndex <= 0) return;
    await goTo(state.chapterKey, state.lessonIndex - 1);
  }

  bool isLastLessonInChapter(Map<String, ChapterData> content) {
    final chapter = content[state.chapterKey];
    if (chapter == null) return false;
    return state.lessonIndex >= chapter.pages.length - 1;
  }
}
