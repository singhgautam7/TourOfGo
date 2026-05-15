import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tour_models.dart';
import '../utils/go_tour_prefs.dart';

class ContentService {
  static const _contentUrl = 'https://go.dev/tour/lesson/';

  /// Fetches from the API, stores raw JSON in SharedPreferences.
  Future<Map<String, ChapterData>> fetchFromApi() async {
    final response = await http.get(
      Uri.parse(_contentUrl),
      headers: {
        'accept': 'application/json, text/plain, */*',
        'x-requested-with': 'XMLHttpRequest',
        'referer': 'https://go.dev/tour/',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Content API returned ${response.statusCode}');
    }

    final raw = response.body;
    final content = parseContentJson(raw);

    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(GoTourPrefs.contentJson, raw);
    await prefs.setString(
      GoTourPrefs.lastFetchTime,
      DateTime.now().millisecondsSinceEpoch.toString(),
    );

    return content;
  }

  /// Loads from SharedPreferences cache. Returns null if not cached.
  Future<Map<String, ChapterData>?> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(GoTourPrefs.contentJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      return parseContentJson(raw);
    } catch (_) {
      return null;
    }
  }

  /// Returns the epoch ms of the last successful fetch, or null.
  Future<int?> getLastFetchTime() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(GoTourPrefs.lastFetchTime);
    if (s == null) return null;
    return int.tryParse(s);
  }
}
