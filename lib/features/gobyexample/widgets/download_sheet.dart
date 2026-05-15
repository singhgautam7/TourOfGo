import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/go_tour_snackbar.dart';
import '../models/download_state.dart';
import '../models/go_example.dart';
import '../providers/go_by_example_download_provider.dart';
import '../providers/go_by_example_index_provider.dart';

/// Opens the "Download All Examples" bottom sheet.
Future<void> showGbeDownloadSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.4, 0.7, 0.95],
      builder: (ctx, scrollController) =>
          _DownloadSheet(scrollController: scrollController),
    ),
  );
}

class _DownloadSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const _DownloadSheet({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final downloadState = ref.watch(goByExampleDownloadNotifierProvider);
    final indexState = ref.watch(goByExampleIndexNotifierProvider);
    final index = indexState.valueOrNull ?? const <GoExampleIndex>[];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KuberRadius.lg),
        ),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          // Drag handle.
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Header.
          Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 8, 16, KuberSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.download_for_offline_rounded,
                    color: cs.primary, size: 22),
                const SizedBox(width: KuberSpacing.md),
                Expanded(
                  child: Text(
                    'Download All Examples',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 16, color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ),
          // Subtitle / status line.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _SubtitleText(
                state: downloadState,
                indexCount: index.length,
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.md),
          // Overall progress.
          if (downloadState.isRunning ||
              downloadState.completed > downloadState.alreadyDownloadedSlugs.length ||
              downloadState.failed > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: downloadState.total > 0
                        ? downloadState.completed / downloadState.total
                        : null,
                    color: cs.primary,
                    backgroundColor: cs.outline,
                    borderRadius: BorderRadius.circular(KuberRadius.full),
                    minHeight: 6,
                  ),
                  const SizedBox(height: KuberSpacing.sm),
                  Text(
                    '${downloadState.completed} of ${downloadState.total} downloaded'
                    '${downloadState.failed > 0 ? ' · ${downloadState.failed} failed' : ''}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: KuberSpacing.md),
          Divider(height: 1, color: cs.outline),
          // Example list.
          Expanded(
            child: index.isEmpty
                ? Center(
                    child: indexState.isLoading
                        ? CircularProgressIndicator(color: cs.primary)
                        : Text(
                            'No examples available.',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: cs.onSurfaceVariant),
                          ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    itemCount: index.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: cs.outline, indent: 52),
                    itemBuilder: (_, i) {
                      final entry = index[i];
                      final status = _statusFor(downloadState, entry);
                      return _DownloadRow(entry: entry, status: status);
                    },
                  ),
          ),
          // Action row.
          Padding(
            padding: const EdgeInsets.fromLTRB(
                20, KuberSpacing.md, 20, KuberSpacing.lg),
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
                showGoTourSnackBar(context,
                    'Downloading examples... Keep the app open.');
              },
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
      style: GoogleFonts.inter(fontSize: 13, color: color, height: 1.5),
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
    final cs = Theme.of(context).colorScheme;

    if (state.isRunning) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onCancel,
          icon: Icon(Icons.stop_rounded, color: cs.error, size: 18),
          label: Text(
            'Cancel Download',
            style: TextStyle(color: cs.error),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
          ),
        ),
      );
    }

    final allDone = indexCount > 0 &&
        state.alreadyDownloadedSlugs.length >= indexCount;
    final startLabel = allDone ? 'Refresh All' : 'Proceed with Download';

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: indexCount == 0 ? null : onStart,
        icon: Icon(
          allDone ? Icons.refresh_rounded : Icons.download_rounded,
          size: 18,
        ),
        label: Text(startLabel),
      ),
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
      DownloadStatus.alreadyDownloaded =>
        Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
      DownloadStatus.done =>
        Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
      DownloadStatus.downloading => SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: cs.primary),
        ),
      DownloadStatus.failed =>
        Icon(Icons.error_outline_rounded, size: 18, color: cs.error),
      DownloadStatus.pending => Icon(
          Icons.radio_button_unchecked_rounded,
          size: 18,
          color: cs.onSurfaceVariant.withValues(alpha: 0.3),
        ),
    };

    final isActive = status.status == DownloadStatus.downloading;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: KuberSpacing.md),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.sm),
              border: Border.all(color: cs.outline),
            ),
            child: Text(
              '${entry.order + 1}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Text(
              entry.title,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? cs.primary : cs.onSurface,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
