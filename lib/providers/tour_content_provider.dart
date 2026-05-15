import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/models/tour_models.dart';
import '../core/utils/content_service.dart';

part 'tour_content_provider.g.dart';

@riverpod
class TourContentNotifier extends _$TourContentNotifier {
  final _service = ContentService();

  @override
  Future<Map<String, ChapterData>> build() async {
    // Offline-first: try cache, then fetch
    final cached = await _service.loadFromCache();
    if (cached != null && cached.isNotEmpty) return cached;
    return fetchFromApi();
  }

  Future<Map<String, ChapterData>> fetchFromApi() async {
    state = const AsyncValue.loading();
    try {
      final content = await _service.fetchFromApi();
      state = AsyncValue.data(content);
      return content;
    } catch (e, st) {
      // If we have stale cache, keep it
      final cached = await _service.loadFromCache();
      if (cached != null && cached.isNotEmpty) {
        state = AsyncValue.data(cached);
        return cached;
      }
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  List<MapEntry<String, ChapterData>> getOrderedChapters() {
    return state.valueOrNull != null
        ? orderedChapters(state.valueOrNull!)
        : [];
  }

  Future<int?> getLastFetchTime() => _service.getLastFetchTime();
}
