import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/go_by_example_service.dart';
import '../../../core/utils/go_tour_prefs.dart';
import '../models/download_state.dart';
import '../models/go_example.dart';

part 'go_by_example_download_provider.g.dart';

/// Orchestrates the bulk "Download All Examples" flow.
///
/// Downloads are sequential to avoid hammering gobyexample.com. A
/// `cancelled` flag is checked between examples for clean cancellation.
@riverpod
class GoByExampleDownloadNotifier extends _$GoByExampleDownloadNotifier {
  final _service = GoByExampleService();

  @override
  DownloadState build() {
    _hydrateAlreadyDownloaded();
    return DownloadState.initial();
  }

  /// Reads the set of slugs that already have cached content. The result is
  /// merged into [state] asynchronously after [build] returns.
  Future<void> _hydrateAlreadyDownloaded() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final slugs = <String>{
      for (final k in keys)
        if (k.startsWith(GoTourPrefs.gbeExamplePrefix))
          k.substring(GoTourPrefs.gbeExamplePrefix.length),
    };
    state = state.copyWith(alreadyDownloadedSlugs: slugs);
  }

  /// Starts a sequential download of every example in [index] that isn't
  /// already cached. Pass `forceRefresh: true` to re-fetch already-downloaded
  /// examples too.
  Future<void> startDownload(
    List<GoExampleIndex> index, {
    bool forceRefresh = false,
  }) async {
    if (state.isRunning) return;

    final prefs = await SharedPreferences.getInstance();
    final alreadyHave = state.alreadyDownloadedSlugs;

    // Build the initial status list. Already-downloaded entries show as such
    // unless we're force-refreshing.
    final statuses = <ExampleDownloadStatus>[
      for (final entry in index)
        ExampleDownloadStatus(
          slug: entry.slug,
          title: entry.title,
          status: (!forceRefresh && alreadyHave.contains(entry.slug))
              ? DownloadStatus.alreadyDownloaded
              : DownloadStatus.pending,
        ),
    ];

    state = state.copyWith(
      isRunning: true,
      cancelled: false,
      total: index.length,
      completed: forceRefresh ? 0 : alreadyHave.length,
      failed: 0,
      statuses: statuses,
    );

    for (int i = 0; i < index.length; i++) {
      if (state.cancelled) break;

      final entry = index[i];
      final existing = statuses[i].status;
      if (!forceRefresh && existing == DownloadStatus.alreadyDownloaded) {
        continue;
      }

      _updateStatus(i, DownloadStatus.downloading);

      try {
        final example = await _service.fetchExample(entry);
        await prefs.setString(
          GoTourPrefs.gbeExamplePrefix + entry.slug,
          jsonEncode(example.toJson()),
        );
        _updateStatus(i, DownloadStatus.done, deltaCompleted: 1);
        state = state.copyWith(
          alreadyDownloadedSlugs: {...state.alreadyDownloadedSlugs, entry.slug},
        );
      } catch (_) {
        _updateStatus(i, DownloadStatus.failed, deltaFailed: 1);
      }
    }

    state = state.copyWith(isRunning: false);
  }

  void cancel() {
    if (!state.isRunning) return;
    state = state.copyWith(cancelled: true);
  }

  void _updateStatus(
    int idx,
    DownloadStatus status, {
    int deltaCompleted = 0,
    int deltaFailed = 0,
  }) {
    final updated = [...state.statuses];
    updated[idx] = updated[idx].copyWith(status: status);
    state = state.copyWith(
      statuses: updated,
      completed: state.completed + deltaCompleted,
      failed: state.failed + deltaFailed,
    );
  }
}
