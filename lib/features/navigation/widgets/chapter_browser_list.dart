import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../providers/progress_provider.dart';

/// Renders the chapter list with expandable lessons. Used both by the
/// home screen progress section and the chapter navigation bottom sheet.
class ChapterBrowserList extends ConsumerStatefulWidget {
  final Map<String, ChapterData> content;
  final String filter;
  final bool useListView;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry padding;
  final bool autoExpandCurrent;
  final VoidCallback? onLessonTapped;

  const ChapterBrowserList({
    super.key,
    required this.content,
    this.filter = '',
    this.useListView = true,
    this.scrollController,
    this.padding = EdgeInsets.zero,
    this.autoExpandCurrent = true,
    this.onLessonTapped,
  });

  @override
  ConsumerState<ChapterBrowserList> createState() =>
      _ChapterBrowserListState();
}

class _ChapterBrowserListState extends ConsumerState<ChapterBrowserList> {
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    if (widget.autoExpandCurrent) {
      final pos = ref.read(lessonPositionNotifierProvider);
      _expanded.add(pos.chapterKey);
    }
  }

  void _onLessonTap(String chapterKey, int lessonIdx) async {
    await ref
        .read(lessonPositionNotifierProvider.notifier)
        .goTo(chapterKey, lessonIdx);
    if (!mounted) return;
    widget.onLessonTapped?.call();
    final pos = ref.read(lessonPositionNotifierProvider);
    if (context.mounted) {
      context.push('/reader', extra: pos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(lessonPositionNotifierProvider);
    final ordered = orderedChapters(widget.content);
    final filter = widget.filter.toLowerCase();
    final filtered = ordered.where((entry) {
      if (filter.isEmpty) return true;
      if ((kChapterDisplayNames[entry.key] ?? entry.value.title)
          .toLowerCase()
          .contains(filter)) {
        return true;
      }
      return entry.value.pages
          .any((l) => l.title.toLowerCase().contains(filter));
    }).toList();

    if (widget.useListView) {
      return ListView.builder(
        controller: widget.scrollController,
        padding: widget.padding,
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final entry = filtered[i];
          return _row(entry, i, filtered.length, position);
        },
      );
    }
    return Column(
      children: List.generate(filtered.length, (i) {
        final entry = filtered[i];
        return _row(entry, i, filtered.length, position);
      }),
    );
  }

  Widget _row(MapEntry<String, ChapterData> entry, int i, int total,
      LessonPosition position) {
    final isExpanded = _expanded.contains(entry.key);
    return ChapterNavRow(
      chapterNum: kChapterOrder.indexOf(entry.key) + 1,
      chapterKey: entry.key,
      chapter: entry.value,
      isExpanded: isExpanded,
      currentPosition: position,
      showDivider: i < total - 1,
      onToggle: () => setState(() {
        if (isExpanded) {
          _expanded.remove(entry.key);
        } else {
          _expanded.add(entry.key);
        }
      }),
      onLessonTap: (lessonIdx) => _onLessonTap(entry.key, lessonIdx),
    );
  }
}

class ChapterNavRow extends ConsumerWidget {
  final int chapterNum;
  final String chapterKey;
  final ChapterData chapter;
  final bool isExpanded;
  final LessonPosition currentPosition;
  final bool showDivider;
  final VoidCallback onToggle;
  final void Function(int) onLessonTap;

  const ChapterNavRow({
    super.key,
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
    const size = 26.0;

    return Container(
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outline)))
          : null,
      child: Column(
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 12),
              child: Row(
                children: [
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
                  SizedBox(
                    width: size,
                    height: size,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(size, size),
                          painter: _RingPainter(
                            progress: pct,
                            color: cs.primary,
                            trackColor: cs.outline,
                          ),
                        ),
                        Text(
                          done ? '✓' : '${(pct * 100).round()}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color:
                                done ? cs.primary : cs.onSurfaceVariant,
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
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 18),
              child: Column(
                children: List.generate(chapter.pages.length, (i) {
                  final lesson = chapter.pages[i];
                  final isCurrent =
                      currentPosition.chapterKey == chapterKey &&
                          currentPosition.lessonIndex == i;
                  final isDone = notifier.isComplete(chapterKey, i);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onLessonTap(i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 2),
                      padding:
                          const EdgeInsets.fromLTRB(28, 8, 10, 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? cs.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(KuberRadius.sm + 2),
                        border: Border(
                          left: BorderSide(
                            color: isCurrent
                                ? cs.primary
                                : Colors.transparent,
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
                              color: isDone
                                  ? cs.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDone
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
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
    const startAngle = -3.14159 / 2;

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
