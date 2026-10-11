import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/tour_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../gobyexample/models/go_example.dart';
import '../../navigation/widgets/chapter_nav_sheet.dart';
import '../models/search_result.dart';
import '../providers/recent_searches_provider.dart';
import 'highlighted_text.dart';

/// One search result: a Kuber card with a type pill, a context line, the
/// highlighted title and an optional excerpt. Matches sit on
/// secondaryContainer in the primary colour.
class _ResultCard extends StatelessWidget {
  final String kind;
  final KuberTone kindTone;
  final String meta;
  final String title;
  final String query;
  final String? excerpt;
  final bool isCompleted;
  final VoidCallback onTap;

  const _ResultCard({
    required this.kind,
    this.kindTone = KuberTone.neutral,
    required this.meta,
    required this.title,
    required this.query,
    this.excerpt,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    TextStyle hl(TextStyle base) => base.copyWith(
          color: cs.onSecondaryContainer,
          backgroundColor: cs.secondaryContainer,
        );
    final titleStyle = theme.textTheme.titleMedium!;
    final excerptStyle =
        theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          KuberSpace.screenMargin, 0, KuberSpace.screenMargin, KuberSpace.cardGap),
      child: KuberCard(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      KuberPill(label: kind, tone: kindTone),
                      const SizedBox(width: KuberSpace.sm),
                      Expanded(
                        child: Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KuberSpace.sm),
                  HighlightedText(
                    text: title,
                    query: query,
                    baseStyle: titleStyle,
                    highlightStyle: hl(titleStyle),
                  ),
                  if (excerpt != null && excerpt!.isNotEmpty) ...[
                    const SizedBox(height: KuberSpace.xs),
                    HighlightedText(
                      text: excerpt!,
                      query: query,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      baseStyle: excerptStyle,
                      highlightStyle: hl(excerptStyle),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: KuberSpace.md),
            isCompleted
                ? Icon(Icons.check_circle_outline_rounded,
                    size: 20, color: cs.primary)
                : const KuberChevron(),
          ],
        ),
      ),
    );
  }
}

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
    final displayTitle =
        kChapterDisplayNames[result.chapterKey] ?? result.chapterTitle;

    return _ResultCard(
      kind: 'Chapter',
      kindTone: KuberTone.primary,
      meta: '${result.completedLessons}/${result.totalLessons} lessons'
          '${result.isCompleted ? ' · Complete' : ''}',
      title: displayTitle,
      query: query,
      isCompleted: result.isCompleted,
      onTap: () {
        ref.read(recentSearchesNotifierProvider.notifier)
            .addSearch(result.chapterTitle);
        context.pop();
        showChapterNavSheet(context, initialChapterKey: result.chapterKey);
      },
    );
  }
}

class LessonResultCard extends ConsumerWidget {
  final LessonSearchResult result;
  final String query;

  const LessonResultCard({
    super.key,
    required this.result,
    required this.query,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterDisplay =
        kChapterDisplayNames[result.chapterKey] ?? result.chapterTitle;

    return _ResultCard(
      kind: 'Lesson',
      meta: 'Ch. ${result.chapterNumber} · $chapterDisplay',
      title: result.lessonTitle,
      query: query,
      excerpt: result.matchedInTitle ? null : result.excerpt,
      isCompleted: result.isCompleted,
      onTap: () {
        ref.read(recentSearchesNotifierProvider.notifier)
            .addSearch(result.lessonTitle);
        // Use push (not pop+push) so back returns to search
        context.push(
          '/reader',
          extra: (
            chapterKey: result.chapterKey,
            lessonIndex: result.lessonIndex,
          ),
        );
      },
    );
  }
}

class ExampleResultCard extends ConsumerWidget {
  final ExampleSearchResult result;
  final String query;

  const ExampleResultCard({
    super.key,
    required this.result,
    required this.query,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ResultCard(
      kind: 'Example',
      meta: 'Go by Example',
      title: result.title,
      query: query,
      isCompleted: result.isCompleted,
      onTap: () {
        ref.read(recentSearchesNotifierProvider.notifier)
            .addSearch(result.title);
        // Pass GoExampleIndex as extra to avoid null cast in the router
        final index = GoExampleIndex(
          slug: result.slug,
          title: result.title,
          order: result.order,
        );
        // Use push so back returns to search
        context.push('/example/${result.slug}', extra: index);
      },
    );
  }
}
