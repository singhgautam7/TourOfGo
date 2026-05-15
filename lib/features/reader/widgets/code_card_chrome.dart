import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg, KuberSpacing.sm, KuberSpacing.sm, 0),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  filename,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 8),
                ],
                _WrapToggle(
                  wrap: wrap,
                  onChanged: (v) => ref
                      .read(settingsNotifierProvider.notifier)
                      .setWrapLines(v),
                  cs: cs,
                ),
              ],
            ),
          ),
          Divider(height: 12, color: cs.outline),
          body,
        ],
      ),
    );
  }
}

class _WrapToggle extends StatelessWidget {
  final bool wrap;
  final ValueChanged<bool> onChanged;
  final ColorScheme cs;

  const _WrapToggle({
    required this.wrap,
    required this.onChanged,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: wrap ? 'Wrap lines: on' : 'Wrap lines: off',
      child: GestureDetector(
        onTap: () => onChanged(!wrap),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: wrap
                ? cs.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(KuberRadius.full),
            border: Border.all(
              color: wrap
                  ? cs.primary.withValues(alpha: 0.4)
                  : cs.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wrap_text_rounded,
                size: 13,
                color: wrap ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'WRAP',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: wrap ? cs.primary : cs.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
