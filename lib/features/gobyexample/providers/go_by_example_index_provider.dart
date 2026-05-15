import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/go_by_example_service.dart';
import '../../../core/utils/go_tour_prefs.dart';
import '../models/go_example.dart';

part 'go_by_example_index_provider.g.dart';

/// Offline-first index of all Go by Example entries.
@riverpod
class GoByExampleIndexNotifier extends _$GoByExampleIndexNotifier {
  final _service = GoByExampleService();

  @override
  Future<List<GoExampleIndex>> build() async {
    final cached = await _loadFromCache();
    if (cached != null && cached.isNotEmpty) return cached;
    return _fetchAndCache();
  }

  Future<List<GoExampleIndex>?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(GoTourPrefs.gbeIndexJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => GoExampleIndex.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<List<GoExampleIndex>> _fetchAndCache() async {
    final index = await _service.fetchIndex();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      GoTourPrefs.gbeIndexJson,
      jsonEncode(index.map((e) => e.toJson()).toList()),
    );
    await prefs.setBool(GoTourPrefs.gbeIndexLoaded, true);
    return index;
  }

  /// Force a re-fetch of the index (used by the download sheet's Refresh).
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final index = await _fetchAndCache();
      state = AsyncValue.data(index);
    } catch (e, st) {
      // Keep stale cache if any.
      final cached = await _loadFromCache();
      if (cached != null && cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
