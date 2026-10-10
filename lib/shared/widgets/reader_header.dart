import 'package:flutter/material.dart';

import '../../core/models/overflow_config.dart';
import '../../core/theme/app_theme.dart';
import 'kuber_app_bar.dart';
import 'kuber_progress.dart';

/// The header of both readers (tour lessons, Go by Example): back, a tonal
/// switcher chip as the title (opens the navigation sheet), info in the
/// overflow, and the reading progress under it. It stays put while the pages
/// under it swipe.
class ReaderHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final VoidCallback onBack;
  final VoidCallback onTitleTap;
  final String infoLabel;
  final VoidCallback onInfo;

  const ReaderHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.onBack,
    required this.onTitleTap,
    required this.infoLabel,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KuberAppBar(
          showBack: true,
          onBack: onBack,
          overflowConfig: KuberOverflowConfig(items: [
            KuberOverflowItem(
              icon: Icons.info_outline_rounded,
              label: infoLabel,
              onTap: onInfo,
            ),
          ]),
          titleWidget: Material(
            color: cs.surfaceContainerHigh,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTitleTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall!
                                .copyWith(color: cs.onSurface),
                          ),
                          Text(subtitle, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: KuberSpace.xs),
                    Icon(Icons.expand_more_rounded,
                        size: 20, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin, 0,
              KuberSpace.screenMargin, KuberSpace.sm),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            builder: (_, value, _) => KuberLinearProgress(value: value),
          ),
        ),
      ],
    );
  }
}
