import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../providers/progress_provider.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';

/// Renders the chapter list with expandable lessons. Used both by the
/// home screen progress section and the chapter navigation bottom sheet.
class ChapterBrowserList extends ConsumerStatefulWidget {
  final Map<String, ChapterData> content;
  final String filter;
  final bool useListView;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry padding;
  final bool autoExpandCurrent;
  final String? initialExpandedChapterKey;
  final VoidCallback? onLessonTapped;

  const ChapterBrowserList({
    super.key,
    required this.content,
    this.filter = '',
    this.useListView = true,
    this.scrollController,
    this.padding = EdgeInsets.zero,
    this.autoExpandCurrent = true,
    this.initialExpandedChapterKey,
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
    if (widget.initialExpandedChapterKey != null) {
      _expanded.add(widget.initialExpandedChapterKey!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToChapter(widget.initialExpandedChapterKey!);
      });
    } else if (widget.autoExpandCurrent) {
      final pos = ref.read(lessonPositionNotifierProvider);
      _expanded.add(pos.chapterKey);
    }
  }

  void _scrollToChapter(String chapterKey) {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;
    final idx = kChapterOrder.indexOf(chapterKey);
    if (idx <= 0) return;
    // Approximate collapsed row height; good enough for "scroll near it".
    final offset = (idx * 72.0)
        .clamp(0.0, controller.position.maxScrollExtent);
    controller.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    ref.watch(progressNotifierProvider);
    final notifier = ref.read(progressNotifierProvider.notifier);
    final total = chapter.pages.length;
    final pct = notifier.chapterProgress(chapterKey, total);
    final done = pct >= 1.0;

    // Grouped-list row (Kuber cards-lists.md): 72 min, 16 / 8 padding, a 40
    // tile, titleMedium + bodyMedium, ring and chevron trailing.
    final header = InkWell(
      onTap: onToggle,
      child: Container(
        constraints: const BoxConstraints(minHeight: KuberSpace.listItem2),
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpace.listRowPadH,
          vertical: KuberSpace.listRowPadV,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done ? cs.primary : cs.secondaryContainer,
                borderRadius: KuberShape.mediumR,
              ),
              child: done
                  ? Icon(Icons.check_rounded, size: 20, color: cs.onPrimary)
                  : Text(
                      '$chapterNum',
                      style: theme.textTheme.labelLarge!
                          .copyWith(color: cs.onSecondaryContainer),
                    ),
            ),
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    kChapterDisplayNames[chapterKey] ?? chapter.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '$total lesson${total == 1 ? '' : 's'}',
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpace.md),
            KuberRingProgress(
              value: pct,
              size: 32,
              stroke: 3,
              child: done
                  ? null
                  : Text(
                      '${(pct * 100).round()}',
                      style: theme.textTheme.labelSmall!.copyWith(
                        fontSize: 9,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(width: KuberSpace.sm),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Icon(Icons.expand_more_rounded,
                  size: 20, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );

    return Container(
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)))
          : null,
      child: Column(
        children: [
          header,
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !isExpanded
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(bottom: KuberSpace.sm),
                    child: Column(
                      children: List.generate(chapter.pages.length, (i) {
                        final isCurrent =
                            currentPosition.chapterKey == chapterKey &&
                                currentPosition.lessonIndex == i;
                        return _LessonRow(
                          title: chapter.pages[i].title,
                          isCurrent: isCurrent,
                          isDone: notifier.isComplete(chapterKey, i),
                          onTap: () => onLessonTap(i),
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// A lesson under an expanded chapter, aligned with the chapter title. The
/// current one sits on secondaryContainer with a "You're here" pill.
class _LessonRow extends StatelessWidget {
  final String title;
  final bool isCurrent;
  final bool isDone;
  final VoidCallback onTap;

  const _LessonRow({
    required this.title,
    required this.isCurrent,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = isCurrent ? cs.onSecondaryContainer : cs.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.sm),
      child: Material(
        color: isCurrent ? cs.secondaryContainer : Colors.transparent,
        borderRadius: KuberShape.mediumR,
        child: InkWell(
          onTap: onTap,
          borderRadius: KuberShape.mediumR,
          child: Container(
            constraints: const BoxConstraints(minHeight: KuberSpace.tapTarget),
            // 8 + 8 puts the dot column under the chapter tile, and the 16
            // gap puts the title under the chapter title.
            padding: const EdgeInsets.symmetric(horizontal: KuberSpace.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDone ? cs.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone ? cs.primary : cs.outline,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: KuberSpace.lg),
                Expanded(
                  child: Text(
                    title,
                    style: (isCurrent
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.bodyMedium)!
                        .copyWith(color: fg),
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: KuberSpace.sm),
                  const KuberPill(label: "You're here", tone: KuberTone.primary),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
