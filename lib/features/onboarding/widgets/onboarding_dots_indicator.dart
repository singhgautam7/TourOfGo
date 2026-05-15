import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OnboardingDotsIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const OnboardingDotsIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (i) {
        final active = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.outline,
            borderRadius: BorderRadius.circular(KuberRadius.full),
          ),
        );
      }),
    );
  }
}
