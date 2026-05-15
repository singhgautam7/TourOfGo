import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/tour_content_provider.dart';
import 'chapter_browser_list.dart';

class ChapterNavSheetContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const ChapterNavSheetContent({
    super.key,
    required this.scrollController,
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
              data: (content) => ChapterBrowserList(
                content: content,
                filter: _search,
                scrollController: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                onLessonTapped: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
