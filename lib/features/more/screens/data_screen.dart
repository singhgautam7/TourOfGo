import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/tour_content_provider.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/go_tour_snackbar.dart';
import '../../../shared/widgets/settings_widgets.dart';

class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: KuberAppBar(showBack: true, title: ''),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const KuberPageHeader(
                      title: 'Data &\nStorage',
                      description: 'Manage cache and progress.',
                    ),

                    // ── PROGRESS ─────────────────────────────────────
                    const SettingsSectionLabel(label: 'PROGRESS'),
                    const SizedBox(height: 8),
                    _Card(
                      cs: cs,
                      child: _ActionRow(
                        icon: Icons.restart_alt_rounded,
                        label: 'Reset all progress',
                        subtitle: 'Clears completed lessons',
                        iconColor: cs.error,
                        cs: cs,
                        onTap: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Reset progress?'),
                              content: const Text(
                                  'This will clear all completed lesson data.'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel')),
                                FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Reset')),
                              ],
                            ),
                          );
                          if (ok == true && context.mounted) {
                            await ref
                                .read(progressNotifierProvider.notifier)
                                .resetAll();
                            if (context.mounted) {
                              showGoTourSnackBar(context, 'Progress cleared.');
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.lg),

                    // ── CONTENT ──────────────────────────────────────
                    const SettingsSectionLabel(label: 'CONTENT'),
                    const SizedBox(height: 8),
                    _Card(
                      cs: cs,
                      child: _ActionRow(
                        icon: Icons.refresh_rounded,
                        label: 'Re-fetch content',
                        subtitle: 'Download latest from go.dev',
                        iconColor: cs.primary,
                        cs: cs,
                        onTap: () async {
                          await ref
                              .read(tourContentNotifierProvider.notifier)
                              .fetchFromApi();
                          if (context.mounted) {
                            showGoTourSnackBar(context, 'Content refreshed.');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final ColorScheme cs;
  const _Card({required this.child, required this.cs});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: child,
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final ColorScheme cs;
  final VoidCallback onTap;
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border:
                    Border.all(color: iconColor.withValues(alpha: 0.25)),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
