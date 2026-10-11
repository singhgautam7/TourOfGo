import 'package:tourgo/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class KuberEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData actionIcon;

  const KuberEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.add_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: cs.onSecondaryContainer,
                size: 32,
              ),
            ),
            const SizedBox(height: KuberSpace.md),
            Text(
              title,
              style: localeFont(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (description.isNotEmpty) const SizedBox(height: KuberSpace.xs),
            if (description.isNotEmpty) Text(
              description,
              style: localeFont(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: KuberSpace.md),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon, size: 20),
                label: Text(
                  actionLabel!,
                  style: localeFont(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}