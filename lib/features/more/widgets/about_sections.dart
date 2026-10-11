// Polished editorial sections for the About screen.
//
// Visual language from Kuber's M3 About (Inter + Instrument Serif italics,
// primary-tint eyebrow, no shadows, outlineVariant borders, radius 20).
// Content adapted for "A Tour of Go".

import 'package:flutter/material.dart';
import 'package:tourgo/core/utils/locale_font.dart';

import '../../../core/theme/app_theme.dart';

/// Section 1: "What is Tour of Go?"
/// Editorial card with a display headline (italic Playfair pull on
/// "learn Go"), supporting paragraph, and a tag rail.
class AboutWhatIsTourOfGoSection extends StatelessWidget {
  const AboutWhatIsTourOfGoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Eyebrow row ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: KuberSpace.sm),
                Text(
                  'WHAT IS TOUR OF GO',
                  style: localeFont(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: cs.outlineVariant),

          // --- Body ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display headline
                Text.rich(
                  TextSpan(
                    style: localeFont(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.4,
                      color: cs.onSurface,
                    ),
                    children: [
                      const TextSpan(text: 'The best way to '),
                      TextSpan(
                        text: 'learn Go',
                        style: serifFont(
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                          height: 1.2,
                        ),
                      ),
                      const TextSpan(text: ', right from your pocket.'),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpace.md),
                Text(
                  "A mobile-first companion for the official Go tour and Go by Example. "
                  "Read lessons, run code, and track your progress. All in one place.",
                  style: localeFont(
                    fontSize: 13.5,
                    color: cs.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),

                // Tag rail
                const SizedBox(height: KuberSpace.md),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: const [
                    _AboutTag('Interactive'),
                    _AboutTag('Offline'),
                    _AboutTag('Trackable'),
                    _AboutTag('Open content'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 2: "The Go Philosophy"
/// Three numbered verses with a gopher-inspired header and a language stamp.
class AboutGoPhilosophySection extends StatelessWidget {
  const AboutGoPhilosophySection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                // Go glyph
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Go',
                    style: serifFont(
                      fontSize: 26,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'THE GO PHILOSOPHY',
                    style: localeFont(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: cs.primary,
                    ),
                  ),
                ),
                // Provenance stamp
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: KuberShape.smallR,
                  ),
                  child: Text(
                    'GOLANG',
                    style: monoFont(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: cs.outlineVariant),

          // --- Verses ---
          _PhilosophyVerse(
            numeral: 'I',
            child: Text.rich(
              TextSpan(
                style: localeFont(
                  fontSize: 13.5,
                  height: 1.55,
                  color: cs.onSurface,
                ),
                children: [
                  TextSpan(
                    text: 'Go',
                    style: localeFont(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const TextSpan(
                    text: ' was created at Google in 2009 to build '
                        'reliable, efficient software at scale.',
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: cs.outlineVariant),
          _PhilosophyVerse(
            numeral: 'II',
            child: Text(
              'Its design favors clarity over cleverness, and simplicity '
              'over abstraction. The language is small by intention.',
              style: localeFont(
                fontSize: 13.5,
                height: 1.55,
                color: cs.onSurface,
              ),
            ),
          ),
          Container(height: 1, color: cs.outlineVariant),
          _PhilosophyVerse(
            numeral: 'III',
            child: Text(
              "Don't communicate by sharing memory.\n"
              "Share memory by communicating.",
              style: serifFont(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                height: 1.5,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhilosophyVerse extends StatelessWidget {
  final String numeral;
  final Widget child;
  const _PhilosophyVerse({required this.numeral, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: Text(
                numeral,
                style: serifFont(
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  color: cs.primary.withValues(alpha: 0.6),
                  height: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _AboutTag extends StatelessWidget {
  final String label;
  const _AboutTag(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: KuberShape.fullR,
      ),
      child: Text(
        label,
        style: localeFont(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cs.onSecondaryContainer,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
