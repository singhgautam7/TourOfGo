import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/go_tour_prefs.dart';

part 'recent_searches_provider.g.dart';

const int _maxRecent = 10;

@riverpod
class RecentSearchesNotifier extends _$RecentSearchesNotifier {
  @override
  List<String> build() {
    _loadFromPrefs();
    return const [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(GoTourPrefs.recentSearches);
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    }
  }

  Future<void> addSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final updated = [
      trimmed,
      ...state.where((s) => s != trimmed),
    ].take(_maxRecent).toList();
    state = updated;
    await _persist(updated);
  }

  Future<void> removeSearch(String query) async {
    final updated = state.where((s) => s != query).toList();
    state = updated;
    await _persist(updated);
  }

  Future<void> clearAll() async {
    state = const [];
    await _persist(const []);
  }

  Future<void> _persist(List<String> searches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(GoTourPrefs.recentSearches, searches);
  }
}
