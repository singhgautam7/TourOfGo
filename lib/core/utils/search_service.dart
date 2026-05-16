import '../models/tour_models.dart';
import '../../features/search/models/search_result.dart';
import '../../features/gobyexample/models/go_example.dart';

/// Pure-Dart, offline full-text search over already-cached tour content.
class SearchService {
  /// Runs a case-insensitive search across chapter titles, lesson titles, and
  /// lesson body HTML (tags stripped). Results are returned sorted by score
  /// descending, then by chapter order (because we iterate in that order).
  List<SearchResult> search({
    required String query,
    required Map<String, ChapterData> content,
    required Map<String, Set<int>> completedLessons,
    List<GoExampleIndex> examples = const [],
    Set<String> completedExamples = const {},
  }) {
    if (query.trim().isEmpty) return [];

    final q = query.toLowerCase().trim();
    final results = <SearchResult>[];

    for (final chapterKey in kChapterOrder) {
      final chapter = content[chapterKey];
      if (chapter == null) continue;

      final chapterNum = kChapterOrder.indexOf(chapterKey) + 1;
      final completed = completedLessons[chapterKey] ?? <int>{};
      final totalLessons = chapter.pages.length;
      final isChapterComplete =
          totalLessons > 0 && completed.length >= totalLessons;

      if (chapter.title.toLowerCase().contains(q)) {
        results.add(ChapterSearchResult(
          chapterKey: chapterKey,
          chapterTitle: chapter.title,
          chapterNumber: chapterNum,
          isCompleted: isChapterComplete,
          completedLessons: completed.length,
          totalLessons: totalLessons,
          score: 100,
        ));
      }

      for (int i = 0; i < chapter.pages.length; i++) {
        final lesson = chapter.pages[i];
        final titleLower = lesson.title.toLowerCase();
        final bodyPlain = _stripHtml(lesson.content);
        final bodyLower = bodyPlain.toLowerCase();
        final isLessonComplete = completed.contains(i);

        if (titleLower.contains(q)) {
          results.add(LessonSearchResult(
            chapterKey: chapterKey,
            chapterTitle: chapter.title,
            chapterNumber: chapterNum,
            lessonIndex: i,
            lessonTitle: lesson.title,
            excerpt: _buildExcerpt(bodyPlain, bodyLower, q),
            matchedInTitle: true,
            isCompleted: isLessonComplete,
            score: 60,
          ));
        } else if (bodyLower.contains(q)) {
          results.add(LessonSearchResult(
            chapterKey: chapterKey,
            chapterTitle: chapter.title,
            chapterNumber: chapterNum,
            lessonIndex: i,
            lessonTitle: lesson.title,
            excerpt: _buildExcerpt(bodyPlain, bodyLower, q),
            matchedInTitle: false,
            isCompleted: isLessonComplete,
            score: 20,
          ));
        }
      }
    }

    for (final ex in examples) {
      if (ex.title.toLowerCase().contains(q)) {
        results.add(ExampleSearchResult(
          slug: ex.slug,
          title: ex.title,
          order: ex.order,
          totalExamples: examples.length,
          isCompleted: completedExamples.contains(ex.slug),
          score: 80,
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#34;', '"')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Builds an excerpt around the first match. [plain] is the original text,
  /// [plainLower] is its lowercase counterpart so we don't lowercase twice.
  String _buildExcerpt(String plain, String plainLower, String query) {
    final idx = plainLower.indexOf(query);
    if (idx == -1) {
      final end = plain.length.clamp(0, 120);
      return plain.substring(0, end);
    }
    final start = (idx - 60).clamp(0, plain.length);
    final end = (idx + query.length + 60).clamp(0, plain.length);
    final raw = plain.substring(start, end).trim();
    final leading = start > 0 ? '...' : '';
    final trailing = end < plain.length ? '...' : '';
    return '$leading$raw$trailing';
  }
}
