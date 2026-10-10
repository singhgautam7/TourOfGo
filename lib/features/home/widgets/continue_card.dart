import 'package:flutter/material.dart';
import 'package:tourgo/core/utils/locale_font.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../providers/progress_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';

class ContinueCard extends ConsumerWidget {
  final Map<String, ChapterData> content;
  final LessonPosition position;
  final VoidCallback onContinue;

  const ContinueCard({
    super.key,
    required this.content,
    required this.position,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final chapter = content[position.chapterKey];
    if (chapter == null) return const SizedBox.shrink();

    final lesson = chapter.pages.length > position.lessonIndex
        ? chapter.pages[position.lessonIndex]
        : null;
    final totalLessons = chapter.pages.length;
    final lessonNum = position.lessonIndex + 1;
    final pct = lessonNum / totalLessons;

    ref.watch(progressNotifierProvider);
    final overall = ref
        .read(progressNotifierProvider.notifier)
        .overallProgress(content);
    final isFreshStart = overall == 0 &&
        position.chapterKey == kChapterOrder.first &&
        position.lessonIndex == 0;

    if (isFreshStart) {
      return KuberCard(
        hero: true,
        child: _EmptyVariantBody(content: content, onStart: onContinue),
      );
    }

    // Hero card (Kuber stat-cards.md): caps label, the lesson as the headline,
    // an 8dp progress bar, and the action.
    return KuberCard(
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONTINUE LEARNING', style: sectionHeaderStyle(context)),
          const SizedBox(height: KuberSpace.sm),
          if (lesson != null)
            Text(lesson.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: KuberSpace.xs),
          Text(
            '${kChapterDisplayNames[position.chapterKey] ?? chapter.title} · Lesson $lessonNum of $totalLessons',
            style: theme.textTheme.bodyMedium!
                .copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: KuberSpace.lg),
          // The wavy M3 indicator, as in the readers' headers.
          KuberLinearProgress(value: pct),
          const SizedBox(height: KuberSpace.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${(pct * 100).round()}% of chapter',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              AppButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                iconAfterLabel: true,
                type: AppButtonType.primary,
                height: 40,
                onPressed: onContinue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyVariantBody extends StatelessWidget {
  final Map<String, ChapterData> content;
  final VoidCallback onStart;

  const _EmptyVariantBody({required this.content, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalChapters = content.length;
    final totalLessons =
        content.values.fold<int>(0, (a, ch) => a + ch.pages.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const KuberIconTile(icon: Icons.flag_outlined),
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start your Go journey',
                      style: theme.textTheme.titleMedium),
                  Text(
                    '$totalChapters chapters · $totalLessons lessons',
                    style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: KuberSpace.lg),
        AppButton(
          label: 'Begin first lesson',
          icon: Icons.arrow_forward_rounded,
          iconAfterLabel: true,
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: onStart,
        ),
      ],
    );
  }
}
