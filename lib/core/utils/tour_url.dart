import '../models/tour_models.dart';
import '../../providers/lesson_position_provider.dart';

/// Canonical URL for a given lesson in the official Go tour.
String tourUrlFor(String chapterKey, int lessonIndex) {
  return 'https://go.dev/tour/$chapterKey/${lessonIndex + 1}';
}

/// Tries to parse a tour URL into a `LessonPosition`. Returns null if the URL
/// is not a `go.dev/tour/<chapter>/<lessonNumber>` style link or the chapter
/// is not recognised.
LessonPosition? tourUrlToPosition(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (!(uri.host == 'go.dev' || uri.host == 'tour.golang.org')) return null;
  final segments = uri.pathSegments;
  // Expected: ["tour", "<chapter>", "<lessonNumber>"]
  final tourIdx = segments.indexOf('tour');
  if (tourIdx < 0 || segments.length < tourIdx + 3) return null;
  final chapterKey = segments[tourIdx + 1];
  if (!kChapterOrder.contains(chapterKey)) return null;
  final lessonNum = int.tryParse(segments[tourIdx + 2]);
  if (lessonNum == null || lessonNum < 1) return null;
  return (chapterKey: chapterKey, lessonIndex: lessonNum - 1);
}
