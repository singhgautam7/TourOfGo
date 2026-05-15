import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/lesson_position_provider.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border(
          left: BorderSide(color: cs.primary, width: 4),
          top: BorderSide(color: cs.outline),
          right: BorderSide(color: cs.outline),
          bottom: BorderSide(color: cs.outline),
        ),
      ),
      padding: const EdgeInsets.all(KuberSpacing.lg),
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
          // Progress bar
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
