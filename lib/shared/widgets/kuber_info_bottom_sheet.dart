import 'package:tourgo/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import '../../core/models/info_config.dart';
import '../../core/theme/app_theme.dart';
import 'kuber_bottom_sheet.dart';
import 'app_button.dart';

class KuberInfoBottomSheet extends StatelessWidget {
  final KuberInfoConfig config;

  const KuberInfoBottomSheet({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayTitle = config.title;
    final displayDescription = config.description;

    return KuberBottomSheet(
      title: displayTitle,
      actions: AppButton(
        label: 'Done',
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayDescription.trim().isNotEmpty) ...[
            Text(
              displayDescription,
              style: localeFont(
                fontSize: 16,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
          ...List.generate(config.items.length, (index) {
            final item = config.items[index];
            final displayItemTitle = item.title;
            final displayItemDescription = item.description;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: KuberShape.mediumR,
                    ),
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: KuberSpace.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayItemTitle,
                          style: localeFont(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          displayItemDescription,
                          style: localeFont(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                            height: 20 / 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          if (config.customChild != null) ...[
            config.customChild!,
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static void show(BuildContext context, KuberInfoConfig config) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KuberInfoBottomSheet(config: config),
    );
  }
}
