import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/tour_content_provider.dart';
import '../../gobyexample/models/go_example.dart';
import '../../gobyexample/providers/go_by_example_index_provider.dart';
import '../../gobyexample/providers/go_by_example_progress_provider.dart';
import '../../gobyexample/providers/go_by_example_download_provider.dart';
import 'chapter_browser_list.dart';

/// Opens the chapter navigation bottom sheet. Optionally [initialChapterKey]
/// pre-expands a chapter and scrolls the list to it.
Future<void> showChapterNavSheet(
  BuildContext context, {
  String? initialChapterKey,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.15,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.15, 0.55, 0.95],
      builder: (ctx, scrollController) => ChapterNavSheetContent(
        scrollController: scrollController,
        initialChapterKey: initialChapterKey,
      ),
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
    final cs = Theme.of(context).colorScheme;
    final contentState = ref.watch(tourContentNotifierProvider);

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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 14),
            child: Row(
              children: [
                Text(
                  'Chapters',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                contentState.maybeWhen(
                  data: (c) {
                    final totalLessons = c.values
                        .fold<int>(0, (a, ch) => a + ch.pages.length);
                    return Text(
                      '${c.length} chapters · $totalLessons lessons',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Search chapters and lessons…',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: cs.onSurfaceVariant),
                prefixIcon: Icon(Icons.search_rounded,
                    color: cs.onSurfaceVariant, size: 18),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: contentState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (content) => SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ChapterBrowserList(
                      content: content,
                      filter: _search,
                      useListView: false,
                      initialExpandedChapterKey: widget.initialChapterKey,
                      onLessonTapped: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    _GbeSection(search: _search),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GbeSection extends ConsumerWidget {
  final String search;
  const _GbeSection({required this.search});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final indexState = ref.watch(goByExampleIndexNotifierProvider);
    final downloadState = ref.watch(goByExampleDownloadNotifierProvider);
    final completed = ref.watch(goByExampleProgressNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 4, vertical: KuberSpacing.sm),
          child: Row(
            children: [
              Expanded(child: Divider(color: cs.outline)),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.md),
                child: Text(
                  'GO BY EXAMPLE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(child: Divider(color: cs.outline)),
            ],
          ),
        ),
        indexState.when(
          loading: () => Padding(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            child: Center(
                child: CircularProgressIndicator(color: cs.primary)),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            child: Text(
              'Could not load examples.',
              style: GoogleFonts.inter(
                  fontSize: 13, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          data: (index) {
            final filter = search.toLowerCase();
            final filtered = index.where((e) {
              if (filter.isEmpty) return true;
              return e.title.toLowerCase().contains(filter);
            }).toList();
            if (filtered.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(KuberSpacing.lg),
                child: Text(
                  'No matching examples.',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
        context.push('/example/${entry.slug}', extra: entry);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            12, KuberSpacing.sm, 12, KuberSpacing.sm),
        child: Row(
          children: [
            // Status dot: filled=complete, outline-primary=downloaded, outline-grey=not.
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isComplete ? cs.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isComplete
                      ? cs.primary
                      : isDownloaded
                          ? cs.primary
                          : cs.onSurfaceVariant.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Text(
                entry.title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: cs.onSurface,
                ),
              ),
            ),
            if (isComplete)
              Icon(Icons.check_circle_rounded,
                  size: 14, color: cs.primary)
            else if (!isDownloaded)
              Icon(
                Icons.download_outlined,
                size: 14,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}
