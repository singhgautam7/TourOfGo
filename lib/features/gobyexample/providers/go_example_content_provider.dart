import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/go_by_example_service.dart';
import '../../../core/utils/go_tour_prefs.dart';
import '../models/go_example.dart';

part 'go_example_content_provider.g.dart';

/// Per-slug example content. Returns `null` when nothing is cached for that
/// slug yet (i.e. user hasn't downloaded it). Call [fetchContent] to download.
@riverpod
class GoExampleContentNotifier extends _$GoExampleContentNotifier {
  final _service = GoByExampleService();

  @override
  Future<GoExample?> build(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(GoTourPrefs.gbeExamplePrefix + slug);
    if (raw == null || raw.isEmpty) return null;
    try {
      return GoExample.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Fetches and caches the example. Sets [AsyncLoading] while in flight.
  Future<void> fetchContent(GoExampleIndex index) async {
    state = const AsyncValue.loading();
    try {
      final example = await _service.fetchExample(index);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        GoTourPrefs.gbeExamplePrefix + index.slug,
        jsonEncode(example.toJson()),
      );
      state = AsyncValue.data(example);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
