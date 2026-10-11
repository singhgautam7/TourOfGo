import 'package:flutter/material.dart';
import 'package:tourgo/core/utils/locale_font.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_list.dart';

/// Welcome, page 2: where the content comes from and what the app does. The
/// dots and buttons live in [OnboardingFlow]'s fixed footer.
class OnboardingPage2 extends StatelessWidget {
  const OnboardingPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const features = [
      (
        icon: Icons.offline_bolt_outlined,
        title: 'Works offline',
        body:
            'Downloaded once, available forever. No internet needed after first load.',
        accent: true,
      ),
      (
        icon: Icons.code_rounded,
        title: 'Run Go code',
        body:
            'Every example is runnable. Output shown inline, powered by the official Go Playground.',
        accent: false,
      ),
      (
        icon: Icons.speed_outlined,
        title: 'Learn your way',
        body:
            'Jump to any chapter. Pick up where you left off. Your progress is saved locally.',
        accent: false,
      ),
    ];

    final theme = Theme.of(context);

    // Centred when it fits, scrollable when the text is large.
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpace.screenMargin,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Straight from\nthe source.',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: KuberSpace.md),
              Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(
                      text: 'All content is fetched directly from ',
                    ),
                    TextSpan(
                      text: 'go.dev',
                      style: monoFont(
                        fontSize: 15,
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text: ', the official Go documentation, not a copy.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpace.xl),
              // Grouped list (Kuber cards-lists.md): 40 tiles, the first in
              // primaryContainer as the lead feature.
              KuberGroup(
                children: [
                  for (final f in features)
                    KuberListRow(
                      leading: KuberIconTile(
                        icon: f.icon,
                        tone: f.accent
                            ? KuberTone.primary
                            : KuberTone.secondary,
                      ),
                      title: f.title,
                      subtitle: f.body,
                      subtitleLines: 3,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
