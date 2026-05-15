import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../providers/progress_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final cs = Theme.of(context).colorScheme;
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
      return _AccentedCard(
        cs: cs,
        child: _EmptyVariantBody(
          content: content,
          onStart: onContinue,
          cs: cs,
        ),
      );
    }

    return _AccentedCard(
      cs: cs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONTINUE LEARNING',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: cs.primary,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Chapter: ${kChapterDisplayNames[position.chapterKey] ?? chapter.title} · Lesson $lessonNum of $totalLessons',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          if (lesson != null)
            Text(
              lesson.title,
              style: GoogleFonts.inter(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.3,
              ),
            ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(KuberRadius.full),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: cs.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(cs.primary),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${(pct * 100).round()}% of chapter',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: onContinue,
                icon: const SizedBox.shrink(),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccentedCard extends StatelessWidget {
  final Widget child;
  final ColorScheme cs;
  const _AccentedCard({required this.child, required this.cs});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          border: Border.all(color: cs.outline),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: cs.primary),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(KuberSpacing.lg),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyVariantBody extends StatelessWidget {
  final Map<String, ChapterData> content;
  final VoidCallback onStart;
  final ColorScheme cs;

  const _EmptyVariantBody({
    required this.content,
    required this.onStart,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final totalChapters = content.length;
    final totalLessons =
        content.values.fold<int>(0, (a, ch) => a + ch.pages.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border:
                    Border.all(color: cs.primary.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.flag_outlined,
                  color: cs.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Start your Go journey',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$totalChapters chapters · $totalLessons lessons',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onStart,
            icon: const SizedBox.shrink(),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Begin first lesson',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
