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
      padding: const EdgeInsets.fromLTRB(
          KuberSpacing.lg, KuberSpacing.sm, KuberSpacing.lg, KuberSpacing.md),
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
    const maxDots = 7;

    if (total <= maxDots) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (i) => _dot(i, current, cs)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.full),
        border: Border.all(color: cs.outline),
      ),
      child: Text(
        '${current + 1} / $total',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
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

}
