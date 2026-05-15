import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

/// Static top bar for the example reader. Mirrors the lesson reader top bar
/// visually (back chip + centered label + spacer for symmetry) but the
/// breadcrumb is non-tappable — examples have no chapter hierarchy.
class ExampleTopBar extends StatelessWidget {
  final String exampleTitle;
  final int currentIndex;
  final int totalExamples;
  final VoidCallback onBack;

  const ExampleTopBar({
    super.key,
    required this.exampleTitle,
    required this.currentIndex,
    required this.totalExamples,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress =
        totalExamples > 0 ? (currentIndex + 1) / totalExamples : 0.0;

    return SafeArea(
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(bottom: BorderSide(color: cs.outline)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(KuberSpacing.md,
                  KuberSpacing.sm, KuberSpacing.md, KuberSpacing.sm),
              child: Row(
                children: [
                  _ChipButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: onBack,
                    cs: cs,
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Go by Example',
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Example ${currentIndex + 1} of $totalExamples',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KuberSpacing.sm),
                  // Spacer slot — keeps the title centered. Could host an
                  // info button in a future pass.
                  const SizedBox(width: 38, height: 38),
                ],
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              builder: (_, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 2,
                backgroundColor: cs.surfaceContainerHigh,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _ChipButton({required this.icon, required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: Icon(icon, size: 20, color: cs.onSurface),
      ),
    );
  }
}
