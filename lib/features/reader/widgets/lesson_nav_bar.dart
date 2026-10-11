import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';

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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin,
              KuberSpace.md, KuberSpace.screenMargin, KuberSpace.md),
          child: Row(
            children: [
              AppButton(
                label: 'Prev',
                icon: Icons.chevron_left_rounded,
                type: AppButtonType.outline,
                height: 40,
                onPressed: currentIndex > 0 ? onPrev : null,
              ),
              const Spacer(),
              _LessonDots(current: currentIndex, total: totalLessons, cs: cs),
              const Spacer(),
              AppButton(
                label: currentIndex == totalLessons - 1 ? 'Done' : 'Next',
                icon: Icons.chevron_right_rounded,
                iconAfterLabel: true,
                type: AppButtonType.primary,
                height: 40,
                onPressed: onNext,
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.fullR,
      ),
      child: Text(
        '${current + 1} / $total',
        style: Theme.of(context)
            .textTheme
            .labelMedium!
            .copyWith(color: cs.onSurfaceVariant),
      ),
    );
  }

  Widget _dot(int idx, int current, ColorScheme cs) {
    final active = idx == current;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: active ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? cs.primary : cs.outlineVariant,
        borderRadius: BorderRadius.circular(KuberShape.full),
      ),
    );
  }

}
