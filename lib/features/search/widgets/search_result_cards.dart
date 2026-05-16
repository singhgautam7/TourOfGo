import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../navigation/widgets/chapter_nav_sheet.dart';
import '../models/search_result.dart';
import 'highlighted_text.dart';

class ChapterResultCard extends ConsumerWidget {
  final ChapterSearchResult result;
  final String query;

  const ChapterResultCard({
    super.key,
    required this.result,
    required this.query,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final displayTitle =
        kChapterDisplayNames[result.chapterKey] ?? result.chapterTitle;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.pop();
        showChapterNavSheet(context, initialChapterKey: result.chapterKey);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg, vertical: KuberSpacing.xs),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 3, color: cs.primary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(KuberSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: KuberSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(KuberRadius.sm),
                          ),
                          child: Text(
                            'CHAPTER',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: KuberSpacing.sm),
                        HighlightedText(
                          text: displayTitle,
                          query: query,
                          baseStyle: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                          highlightStyle: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            backgroundColor:
                                cs.primary.withValues(alpha: 0.12),
                          ),
                        ),
                        const SizedBox(height: KuberSpacing.xs),
                        Row(
                          children: [
                            Text(
                              '${result.completedLessons}/${result.totalLessons} lessons',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            if (result.isCompleted) ...[
                              const SizedBox(width: KuberSpacing.sm),
                              Icon(Icons.check_circle_rounded,
                                  size: 14, color: cs.primary),
                              const SizedBox(width: 2),
                              Text(
                                'Complete',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: cs.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(right: KuberSpacing.md),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LessonResultCard extends StatelessWidget {
  final LessonSearchResult result;
  final String query;

  const LessonResultCard({
    super.key,
    required this.result,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final chapterDisplay =
        kChapterDisplayNames[result.chapterKey] ?? result.chapterTitle;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.pop();
        context.push(
          '/reader',
          extra: (
            chapterKey: result.chapterKey,
            lessonIndex: result.lessonIndex,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg, vertical: KuberSpacing.xs),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(KuberRadius.sm),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Text(
                      'LESSON',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  Expanded(
                    child: Text(
                      'Ch. ${result.chapterNumber} · $chapterDisplay',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (result.isCompleted)
                    Icon(Icons.check_circle_rounded,
                        size: 14, color: cs.primary),
                ],
              ),
              const SizedBox(height: KuberSpacing.sm),
              HighlightedText(
                text: result.lessonTitle,
                query: query,
                baseStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                highlightStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                  backgroundColor: cs.primary.withValues(alpha: 0.12),
                ),
              ),
              if (!result.matchedInTitle && result.excerpt.isNotEmpty) ...[
                const SizedBox(height: KuberSpacing.sm),
                HighlightedText(
                  text: result.excerpt,
                  query: query,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  baseStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                  highlightStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.primary,
                    height: 1.5,
                    backgroundColor: cs.primary.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ExampleResultCard extends StatelessWidget {
  final ExampleSearchResult result;
  final String query;

  const ExampleResultCard({
    super.key,
    required this.result,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        context.pop();
        context.push('/example/${result.slug}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg, vertical: KuberSpacing.xs),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(KuberRadius.sm),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Text(
                      'EXAMPLE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  Expanded(
                    child: Text(
                      'Go by Example',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (result.isCompleted)
                    Icon(Icons.check_circle_rounded,
                        size: 14, color: cs.primary),
                ],
              ),
              const SizedBox(height: KuberSpacing.sm),
              HighlightedText(
                text: result.title,
                query: query,
                baseStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                highlightStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                  backgroundColor: cs.primary.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
