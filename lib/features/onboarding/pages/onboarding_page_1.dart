import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Welcome, page 1: the Go glyph and the headline. The dots and buttons live
/// in [OnboardingFlow]'s fixed footer, so only this content swipes.
class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The app icon's own Go glyph, in its night tones on dark.
          Center(
            child: Image.asset(
              theme.brightness == Brightness.dark
                  ? 'assets/go_mark_dark.png'
                  : 'assets/go_mark.png',
              width: 180,
              height: 180,
            ),
          ),
          const SizedBox(height: KuberSpace.xxl),
          Text('Go,\nfrom zero.', style: theme.textTheme.displaySmall),
          const SizedBox(height: KuberSpace.md),
          Text(
            'The official Go tour, redesigned for your phone. Read, run, and learn, offline.',
            style: theme.textTheme.bodyLarge!.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
