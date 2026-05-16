import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/go_tour_prefs.dart';

part 'go_by_example_progress_provider.g.dart';

@riverpod
class GoByExampleProgressNotifier extends _$GoByExampleProgressNotifier {
  @override
  Set<String> build() {
    _loadFromPrefs();
    return const {};
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(GoTourPrefs.gbeCompleted);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = (jsonDecode(raw) as List<dynamic>).cast<String>().toSet();
      state = list;
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        GoTourPrefs.gbeCompleted, jsonEncode(state.toList()));
  }

  Future<void> markComplete(String slug) async {
    if (state.contains(slug)) return;
    state = {...state, slug};
    await _persist();
  }

  bool isComplete(String slug) => state.contains(slug);

  double overallProgress(int totalCount) {
    if (totalCount == 0) return 0;
    return state.length / totalCount;
  }

  Future<void> resetAll() async {
    state = const {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(GoTourPrefs.gbeCompleted);
  }
}
