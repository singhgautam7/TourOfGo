import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/tour_content_provider.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../providers/progress_provider.dart';

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
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    // Auto-expand current chapter
    final pos = ref.read(lessonPositionNotifierProvider);
    _expanded.add(pos.chapterKey);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final contentState = ref.watch(tourContentNotifierProvider);
    final position = ref.watch(lessonPositionNotifierProvider);

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
          // Handle
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

          // Header
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

          // Search
          Padding(
            padding:
                const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: TextField(
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
              style:
                  GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'Search chapters and lessons…',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: cs.onSurfaceVariant),
                prefixIcon:
                    Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 18),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                isDense: true,
              ),
            ),
          ),

          // Chapter list
          Expanded(
            child: contentState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (content) {
                final ordered = orderedChapters(content);
                final filtered = ordered.where((entry) {
                  if (_search.isEmpty) return true;
                  if (entry.value.title.toLowerCase().contains(_search)) {
                    return true;
                  }
                  return entry.value.pages
                      .any((l) => l.title.toLowerCase().contains(_search));
                }).toList();

                return ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final entry = filtered[i];
                    final isExpanded = _expanded.contains(entry.key);
                    return _ChapterNavRow(
                      chapterNum: kChapterOrder.indexOf(entry.key) + 1,
                      chapterKey: entry.key,
                      chapter: entry.value,
                      isExpanded: isExpanded,
                      currentPosition: position,
                      showDivider: i < filtered.length - 1,
                      onToggle: () => setState(() {
                        if (isExpanded) {
                          _expanded.remove(entry.key);
                        } else {
                          _expanded.add(entry.key);
                        }
                      }),
                      onLessonTap: (lessonIdx) async {
                        await ref
                            .read(lessonPositionNotifierProvider.notifier)
                            .goTo(entry.key, lessonIdx);
                        if (context.mounted) {
                          Navigator.pop(context);
                          final pos =
                              ref.read(lessonPositionNotifierProvider);
                          context.push('/reader', extra: pos);
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterNavRow extends ConsumerWidget {
  final int chapterNum;
  final String chapterKey;
  final ChapterData chapter;
  final bool isExpanded;
  final LessonPosition currentPosition;
  final bool showDivider;
  final VoidCallback onToggle;
  final void Function(int) onLessonTap;

  const _ChapterNavRow({
    required this.chapterNum,
    required this.chapterKey,
    required this.chapter,
    required this.isExpanded,
    required this.currentPosition,
    required this.showDivider,
    required this.onToggle,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    ref.watch(progressNotifierProvider);
    final notifier = ref.read(progressNotifierProvider.notifier);
    final total = chapter.pages.length;
    final pct = notifier.chapterProgress(chapterKey, total);
    final done = pct >= 1.0;
    final size = 26.0;

    return Container(
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outline)))
          : null,
      child: Column(
        children: [
          // Chapter row header
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 6),
              child: Row(
                children: [
                  // Badge
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: done ? cs.primary : cs.surfaceContainerHigh,
                      borderRadius:
                          BorderRadius.circular(KuberRadius.sm + 2),
                      border: Border.all(
                          color: done ? cs.primary : cs.outline),
                    ),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white)
                          : Text(
                              '$chapterNum',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kChapterDisplayNames[chapterKey] ?? chapter.title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Text(
                          '$total lesson${total == 1 ? '' : 's'}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11.5,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ring progress
                  SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size(size, size),
                          painter: _RingPainter(
                            progress: pct,
                            color: cs.primary,
                            trackColor: cs.outline,
                          ),
                        ),
                        Text(
                          done
                              ? '✓'
                              : '${(pct * 100).round()}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: done
                                ? cs.primary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Lesson list (expanded)
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 14),
              child: Column(
                children: List.generate(chapter.pages.length, (i) {
                  final lesson = chapter.pages[i];
                  final isCurrent = currentPosition.chapterKey == chapterKey &&
                      currentPosition.lessonIndex == i;
                  final isDone =
                      notifier.isComplete(chapterKey, i);
                  return GestureDetector(
                    onTap: () => onLessonTap(i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding: const EdgeInsets.fromLTRB(28, 8, 10, 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? cs.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(KuberRadius.sm + 2),
                        border: Border(
                          left: BorderSide(
                            color: isCurrent ? cs.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color:
                                  isDone ? cs.primary : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isDone ? cs.primary : cs.onSurfaceVariant,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                color: isCurrent
                                    ? cs.primary
                                    : cs.onSurface,
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Text(
                              "You're here",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                                letterSpacing: 0.8,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2.5;
    const startAngle = -3.14159 / 2; // -90°

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progress * 2 * 3.14159,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress;
}
