import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class LessonNavBar extends StatelessWidget {
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final int currentIndex;
  final int totalLessons;

  const LessonNavBar({
    super.key,
    required this.onPrev,
    required this.onNext,
    required this.currentIndex,
    required this.totalLessons,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg, vertical: KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: currentIndex > 0 ? onPrev : null,
            icon: const Icon(Icons.chevron_left_rounded, size: 18),
            label: Text(
              'Prev',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          _LessonDots(
            current: currentIndex,
            total: totalLessons,
            cs: cs,
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: onNext,
            icon: const SizedBox.shrink(),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentIndex == totalLessons - 1 ? 'Done' : 'Next',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonDots extends StatelessWidget {
  final int current;
  final int total;
  final ColorScheme cs;

  const _LessonDots({
    required this.current,
    required this.total,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    // Show up to 7 dots; with ellipsis for larger sets
    const maxDots = 7;

    if (total <= maxDots) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (i) => _dot(i, current, cs)),
      );
    }

    // Complex case: show a window around current
    final List<Widget> dots = [];
    int start = (current - 2).clamp(0, total - maxDots);
    int end = (start + maxDots - 1).clamp(0, total - 1);

    if (start > 0) {
      dots.add(_ellipsis(cs));
    }
    for (int i = start; i <= end; i++) {
      dots.add(_dot(i, current, cs));
    }
    if (end < total - 1) {
      dots.add(_ellipsis(cs));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: dots);
  }

  Widget _dot(int idx, int current, ColorScheme cs) {
    final active = idx == current;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: active ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? cs.primary : cs.outline,
        borderRadius: BorderRadius.circular(KuberRadius.full),
      ),
    );
  }

  Widget _ellipsis(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        '…',
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
      ),
    );
  }
}
