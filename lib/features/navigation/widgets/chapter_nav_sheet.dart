import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/tour_content_provider.dart';
import '../../gobyexample/models/go_example.dart';
import '../../gobyexample/providers/go_by_example_index_provider.dart';
import '../../gobyexample/providers/go_by_example_progress_provider.dart';
import '../../gobyexample/providers/go_by_example_download_provider.dart';
import '../../../shared/widgets/nav_sheet.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'chapter_browser_list.dart';

/// Opens the chapter navigation bottom sheet. Optionally [initialChapterKey]
/// pre-expands a chapter and scrolls the list to it.
Future<void> showChapterNavSheet(
  BuildContext context, {
  String? initialChapterKey,
}) {
  return showNavSheet(
    context,
    builder: (scrollController) => ChapterNavSheetContent(
      scrollController: scrollController,
      initialChapterKey: initialChapterKey,
    ),
  );
}

class ChapterNavSheetContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final String? initialChapterKey;

  const ChapterNavSheetContent({
    super.key,
    required this.scrollController,
    this.initialChapterKey,
  });

  @override
  ConsumerState<ChapterNavSheetContent> createState() =>
      _ChapterNavSheetContentState();
}

class _ChapterNavSheetContentState
    extends ConsumerState<ChapterNavSheetContent> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final contentState = ref.watch(tourContentNotifierProvider);

    return NavSheetFrame(
      title: 'Chapters',
      subtitle: contentState.maybeWhen(
        data: (c) {
          final totalLessons =
              c.values.fold<int>(0, (a, ch) => a + ch.pages.length);
          return '${c.length} chapters · $totalLessons lessons';
        },
        orElse: () => null,
      ),
      searchHint: 'Search chapters and lessons…',
      onSearch: (v) => setState(() => _search = v),
      child: contentState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => KuberEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Error',
          description: '$e',
        ),
        data: (content) => SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(
              KuberSpace.screenMargin, 0, KuberSpace.screenMargin, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KuberGroup(
                children: [
                  ChapterBrowserList(
                    content: content,
                    filter: _search,
                    useListView: false,
                    initialExpandedChapterKey: widget.initialChapterKey,
                    onLessonTapped: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: KuberSpace.sectionGap),
              _GbeSection(search: _search),
            ],
          ),
        ),
      ),
    );
  }
}

class _GbeSection extends ConsumerWidget {
  final String search;
  const _GbeSection({required this.search});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final indexState = ref.watch(goByExampleIndexNotifierProvider);
    final downloadState = ref.watch(goByExampleDownloadNotifierProvider);
    final completed = ref.watch(goByExampleProgressNotifierProvider);
    final note = theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KuberSectionHeader(title: 'Go by Example'),
        indexState.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(KuberSpace.lg),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(KuberSpace.lg),
            child: Text('Could not load examples.',
                style: note, textAlign: TextAlign.center),
          ),
          data: (index) {
            final filter = search.toLowerCase();
            final filtered = index.where((e) {
              if (filter.isEmpty) return true;
              return e.title.toLowerCase().contains(filter);
            }).toList();
            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(KuberSpace.lg),
                child: Text('No matching examples.',
                    style: note, textAlign: TextAlign.center),
              );
            }
            return KuberGroup(
              children: [
                for (final e in filtered)
                  _GbeNavRow(
                    entry: e,
                    isComplete: completed.contains(e.slug),
                    isDownloaded:
                        downloadState.alreadyDownloadedSlugs.contains(e.slug),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GbeNavRow extends StatelessWidget {
  final GoExampleIndex entry;
  final bool isComplete;
  final bool isDownloaded;

  const _GbeNavRow({
    required this.entry,
    required this.isComplete,
    required this.isDownloaded,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return KuberListRow(
      dense: true,
      minHeight: KuberSpace.tapTarget,
      onTap: () {
        Navigator.pop(context);
        context.push('/example/${entry.slug}', extra: entry);
      },
      // Status dot: filled = complete, primary ring = downloaded, grey ring
      // = not yet.
      leading: SizedBox(
        width: 24,
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isComplete ? cs.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isComplete || isDownloaded ? cs.primary : cs.outline,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
      title: entry.title,
      trailing: isComplete
          ? Icon(Icons.check_circle_outline_rounded,
              size: 20, color: cs.primary)
          : !isDownloaded
              ? Icon(Icons.download_outlined,
                  size: 20, color: cs.onSurfaceVariant)
              : null,
    );
  }
}
