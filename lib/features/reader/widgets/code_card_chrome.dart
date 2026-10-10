import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tourgo/core/utils/locale_font.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/settings_provider.dart';

/// Shared card chrome for any code surface (read-only or editable):
/// rounded outline + a file-name header row with a compact wrap-lines
/// toggle synced with global settings + a divider + the body.
class CodeCardChrome extends ConsumerWidget {
  final String filename;
  final Widget body;
  final Widget? trailing;

  const CodeCardChrome({
    super.key,
    required this.filename,
    required this.body,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final wrap = ref.watch(settingsNotifierProvider).wrapLines;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.largeR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpace.lg, KuberSpace.sm, KuberSpace.sm, KuberSpace.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    filename,
                    overflow: TextOverflow.ellipsis,
                    style: monoFont(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: KuberSpace.sm),
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: KuberSpace.sm),
                ],
                // M3 filter chip (Kuber controls.md): r8, 32 high, selected
                // secondaryContainer with a check.
                FilterChip(
                  label: const Text('Wrap'),
                  selected: wrap,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  tooltip: wrap ? 'Wrap lines: on' : 'Wrap lines: off',
                  onSelected: (v) => ref
                      .read(settingsNotifierProvider.notifier)
                      .setWrapLines(v),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
          const SizedBox(height: KuberSpace.sm),
          body,
        ],
      ),
    );
  }
}
