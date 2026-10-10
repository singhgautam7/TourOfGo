import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../shared/widgets/nav_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../models/download_state.dart';
import '../models/go_example.dart';
import '../providers/go_by_example_download_provider.dart';
import '../providers/go_by_example_index_provider.dart';

/// Opens the "Download All Examples" bottom sheet.
Future<void> showGbeDownloadSheet(BuildContext context) {
  return showNavSheet(
    context,
    builder: (scrollController) =>
        _DownloadSheet(scrollController: scrollController),
  );
}

class _DownloadSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const _DownloadSheet({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final downloadState = ref.watch(goByExampleDownloadNotifierProvider);
    final indexState = ref.watch(goByExampleIndexNotifierProvider);
    final index = indexState.valueOrNull ?? const <GoExampleIndex>[];
    final showProgress = downloadState.isRunning ||
        downloadState.completed >
            downloadState.alreadyDownloadedSlugs.length ||
        downloadState.failed > 0;

    return NavSheetFrame(
      title: 'Download All Examples',
      leading: const KuberIconTile(icon: Icons.download_for_offline_outlined),
      child: Column(
        children: [
          Expanded(
            child: index.isEmpty
                ? Center(
                    child: indexState.isLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            'No examples available.',
                            style: theme.textTheme.bodyMedium!
                                .copyWith(color: cs.onSurfaceVariant),
                          ),
                  )
                : SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                        KuberSpace.screenMargin, 0, KuberSpace.screenMargin,
                        KuberSpace.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SubtitleText(
                          state: downloadState,
                          indexCount: index.length,
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: !showProgress
                              ? const SizedBox(width: double.infinity)
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      top: KuberSpace.lg),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      KuberLinearProgress(
                                        value: downloadState.total > 0
                                            ? downloadState.completed /
                                                downloadState.total
                                            : 0,
                                      ),
                                      const SizedBox(height: KuberSpace.sm),
                                      Text(
                                        '${downloadState.completed} of ${downloadState.total} downloaded'
                                        '${downloadState.failed > 0 ? ' · ${downloadState.failed} failed' : ''}',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        const SizedBox(height: KuberSpace.lg),
                        KuberGroup(
                          children: [
                            for (final entry in index)
                              _DownloadRow(
                                entry: entry,
                                status: _statusFor(downloadState, entry),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          // Pinned actions (Kuber sheets: 16 / 20 / 24).
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: _ActionRow(
                state: downloadState,
                indexCount: index.length,
                onCancel: () => ref
                    .read(goByExampleDownloadNotifierProvider.notifier)
                    .cancel(),
                onStart: () {
                  final allDone =
                      downloadState.alreadyDownloadedSlugs.length >=
                              index.length &&
                          index.isNotEmpty;
                  ref
                      .read(goByExampleDownloadNotifierProvider.notifier)
                      .startDownload(index, forceRefresh: allDone);
                  showKuberSnackBar(context,
                      'Downloading examples... Keep the app open.');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  ExampleDownloadStatus _statusFor(
      DownloadState state, GoExampleIndex entry) {
    final inFlight = state.statuses
        .where((s) => s.slug == entry.slug)
        .cast<ExampleDownloadStatus?>()
        .firstWhere((_) => true, orElse: () => null);
    if (inFlight != null) return inFlight;
    return ExampleDownloadStatus(
      slug: entry.slug,
      title: entry.title,
      status: state.alreadyDownloadedSlugs.contains(entry.slug)
          ? DownloadStatus.alreadyDownloaded
          : DownloadStatus.pending,
    );
  }
}

class _SubtitleText extends StatelessWidget {
  final DownloadState state;
  final int indexCount;
  const _SubtitleText({required this.state, required this.indexCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final allDownloaded = indexCount > 0 &&
        state.alreadyDownloadedSlugs.length >= indexCount &&
        !state.isRunning &&
        state.completed == state.alreadyDownloadedSlugs.length;

    String message;
    Color color = cs.onSurfaceVariant;
    if (state.isRunning) {
      message = 'Downloading... Keep the app open until complete.';
    } else if (state.total > 0 && state.completed == state.total &&
        state.failed == 0) {
      message = 'All examples downloaded successfully.';
      color = cs.primary;
    } else if (allDownloaded) {
      message =
          'You have all $indexCount examples downloaded already. You can refresh, but Go by Example rarely changes.';
    } else {
      final remaining =
          indexCount - state.alreadyDownloadedSlugs.length;
      message =
          '$remaining of $indexCount examples will be fetched from gobyexample.com and saved on your device for offline reading.';
    }

    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: color),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final DownloadState state;
  final int indexCount;
  final VoidCallback onCancel;
  final VoidCallback onStart;

  const _ActionRow({
    required this.state,
    required this.indexCount,
    required this.onCancel,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isRunning) {
      return AppButton(
        label: 'Cancel Download',
        icon: Icons.stop_rounded,
        type: AppButtonType.danger,
        fullWidth: true,
        onPressed: onCancel,
      );
    }

    final allDone = indexCount > 0 &&
        state.alreadyDownloadedSlugs.length >= indexCount;
    final startLabel = allDone ? 'Refresh All' : 'Proceed with Download';

    return AppButton(
      label: startLabel,
      icon: allDone ? Icons.refresh_rounded : Icons.download_rounded,
      type: AppButtonType.primary,
      fullWidth: true,
      onPressed: indexCount == 0 ? null : onStart,
    );
  }
}

class _DownloadRow extends StatelessWidget {
  final GoExampleIndex entry;
  final ExampleDownloadStatus status;

  const _DownloadRow({required this.entry, required this.status});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final trailing = switch (status.status) {
      DownloadStatus.alreadyDownloaded => Icon(
          Icons.check_circle_outline_rounded, size: 20, color: cs.primary),
      DownloadStatus.done => Icon(
          Icons.check_circle_outline_rounded, size: 20, color: cs.primary),
      DownloadStatus.downloading => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      DownloadStatus.failed =>
        Icon(Icons.error_outline_rounded, size: 20, color: cs.error),
      DownloadStatus.pending => Icon(Icons.radio_button_unchecked_rounded,
          size: 20, color: cs.outline),
    };

    final theme = Theme.of(context);
    final isActive = status.status == DownloadStatus.downloading;
    return KuberListRow(
      dense: true,
      selected: isActive,
      minHeight: KuberSpace.tapTarget,
      leading: SizedBox(
        width: 24,
        child: Text(
          '${entry.order + 1}',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium!.copyWith(
            color: isActive ? cs.onSecondaryContainer : cs.onSurfaceVariant,
          ),
        ),
      ),
      title: entry.title,
      trailing: trailing,
    );
  }
}
