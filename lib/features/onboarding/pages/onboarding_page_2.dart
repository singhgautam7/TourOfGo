import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/go_tour_button.dart';
import '../widgets/onboarding_dots_indicator.dart';

class OnboardingPage2 extends StatelessWidget {
  final VoidCallback onStart;

  const OnboardingPage2({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const features = [
      (
        icon: Icons.offline_bolt_rounded,
        title: 'Works offline',
        body: 'Downloaded once, available forever. No internet needed after first load.',
        accent: true,
      ),
      (
        icon: Icons.code_rounded,
        title: 'Run Go code',
        body: 'Every example is runnable. Output shown inline — powered by the official Go Playground.',
        accent: false,
      ),
      (
        icon: Icons.speed_rounded,
        title: 'Learn your way',
        body: 'Jump to any chapter. Pick up where you left off. Your progress is saved locally.',
        accent: false,
      ),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 34),
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  _GoMark(cs: cs),
                  const SizedBox(width: 10),
                  Text(
                    'Tour of Go',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Straight from\nthe source.',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.08,
                      letterSpacing: -0.9,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                            text: 'All content is fetched directly from '),
                        TextSpan(
                          text: 'go.dev',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(
                            text:
                                ' — the official Go documentation, not a copy.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  ...features.map((f) => _FeatureCard(feature: f, cs: cs)),
                ],
              ),
            ),

            Column(
              children: [
                OnboardingDotsIndicator(pageCount: 2, currentPage: 1),
                const SizedBox(height: 18),
                GoTourButton(
                  label: 'Start learning',
                  icon: Icons.arrow_forward_rounded,
                  iconAfterLabel: true,
                  type: GoTourButtonType.primary,
                  fullWidth: true,
                  onPressed: onStart,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final ({IconData icon, String title, String body, bool accent}) feature;
  final ColorScheme cs;
  const _FeatureCard({required this.feature, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(
          color: feature.accent
              ? cs.primary.withValues(alpha: 0.45)
              : cs.outline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: feature.accent
                  ? cs.primary.withValues(alpha: 0.12)
                  : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Icon(
              feature.icon,
              size: 20,
              color: feature.accent ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  feature.body,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoMark extends StatelessWidget {
  final ColorScheme cs;
  const _GoMark({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Icon(Icons.circle_outlined, color: cs.primary, size: 16),
      ),
    );
  }
}
