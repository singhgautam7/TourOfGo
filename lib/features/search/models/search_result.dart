/// Result types produced by [SearchService.search].
sealed class SearchResult {
  int get score;
}

class ChapterSearchResult extends SearchResult {
  final String chapterKey;
  final String chapterTitle;
  final int chapterNumber;
  final bool isCompleted;
  final int completedLessons;
  final int totalLessons;
  @override
  final int score;

  ChapterSearchResult({
    required this.chapterKey,
    required this.chapterTitle,
    required this.chapterNumber,
    required this.isCompleted,
    required this.completedLessons,
    required this.totalLessons,
    required this.score,
  });
}

class LessonSearchResult extends SearchResult {
  final String chapterKey;
  final String chapterTitle;
  final int chapterNumber;
  final int lessonIndex;
  final String lessonTitle;
  final String excerpt;
  final bool matchedInTitle;
  final bool isCompleted;
  @override
  final int score;

  LessonSearchResult({
    required this.chapterKey,
    required this.chapterTitle,
    required this.chapterNumber,
    required this.lessonIndex,
    required this.lessonTitle,
    required this.excerpt,
    required this.matchedInTitle,
    required this.isCompleted,
    required this.score,
  });
}
