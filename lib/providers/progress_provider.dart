import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/tour_models.dart';
import '../core/utils/go_tour_prefs.dart';

part 'progress_provider.g.dart';

@riverpod
class ProgressNotifier extends _$ProgressNotifier {
  @override
  Map<String, Set<int>> build() {
    _loadFromPrefs();
    return {};
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(GoTourPrefs.completedJson);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final map = decoded.map((k, v) {
        final list = (v as List<dynamic>).map((e) => e as int).toSet();
        return MapEntry(k, list);
      });
      state = map;
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final serialized = state.map((k, v) => MapEntry(k, v.toList()));
    await prefs.setString(GoTourPrefs.completedJson, jsonEncode(serialized));
  }

  Future<void> markComplete(String chapterKey, int lessonIndex) async {
    final updated = Map<String, Set<int>>.from(state);
    updated[chapterKey] = {...(updated[chapterKey] ?? {}), lessonIndex};
    state = updated;
    await _persist();
  }

  bool isComplete(String chapterKey, int lessonIndex) {
    return state[chapterKey]?.contains(lessonIndex) ?? false;
  }

  double chapterProgress(String chapterKey, int totalLessons) {
    if (totalLessons == 0) return 0;
    final done = state[chapterKey]?.length ?? 0;
    return done / totalLessons;
  }

  double overallProgress(Map<String, ChapterData> content) {
    int total = 0;
    int done = 0;
    for (final entry in content.entries) {
      total += entry.value.pages.length;
      done += state[entry.key]?.length ?? 0;
    }
    if (total == 0) return 0;
    return done / total;
  }

  Future<void> resetAll() async {
    state = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(GoTourPrefs.completedJson);
  }
}
