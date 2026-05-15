import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/search_service.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/tour_content_provider.dart';
import '../models/search_result.dart';

part 'search_provider.g.dart';

class SearchState {
  final String query;
  final List<SearchResult> results;
  final bool hasSearched;
  const SearchState({
    required this.query,
    required this.results,
    required this.hasSearched,
  });

  static const empty =
      SearchState(query: '', results: [], hasSearched: false);
}

@riverpod
class SearchNotifier extends _$SearchNotifier {
  final _service = SearchService();

  @override
  SearchState build() => SearchState.empty;

  void runSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = SearchState.empty;
      return;
    }
    final content =
        ref.read(tourContentNotifierProvider).valueOrNull ?? const {};
    final completed = ref.read(progressNotifierProvider);
    final results = _service.search(
      query: trimmed,
      content: content,
      completedLessons: completed,
    );
    state =
        SearchState(query: trimmed, results: results, hasSearched: true);
  }

  void clear() => state = SearchState.empty;
}
