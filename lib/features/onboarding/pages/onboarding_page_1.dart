import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/onboarding_dots_indicator.dart';

class OnboardingPage1 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingPage1({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 8, 28, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: brand + skip
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  Text(
                    'Tour of Go',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onSkip,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hero illustration + headline
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The app icon's own Go glyph, in its night tones on dark.
                  Center(
                    child: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/go_mark_dark.png'
                          : 'assets/go_mark.png',
                      width: 180,
                      height: 180,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Go,\nfrom zero.',
                    style: GoogleFonts.inter(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.05,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'The official Go tour, redesigned for your phone. Read, run, and learn — offline.',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: cs.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),

            // Footer: dots + button
            Column(
              children: [
                OnboardingDotsIndicator(pageCount: 2, currentPage: 0),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: onNext,
                    icon: const SizedBox.shrink(),
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get started',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
