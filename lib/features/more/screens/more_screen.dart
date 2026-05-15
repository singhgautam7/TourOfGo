import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/go_tour_snackbar.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

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
                    // Page header
                    const KuberPageHeader(
                      title: 'More',
                      description: 'Settings, data, and about.',
                    ),

                    // ── LEARN ──────────────────────────────────────────
                    _SectionTitle('LEARN', cs: cs),
                    const SizedBox(height: 8),
                    _MenuCard(
                      cs: cs,
                      items: [
                        _MenuItem(
                          icon: Icons.restart_alt_rounded,
                          iconColor: cs.error,
                          label: 'Reset progress',
                          subtitle: 'Clear all completed lessons',
                          isDestructive: true,
                          onTap: () => _confirmResetProgress(context, ref),
                          cs: cs,
                        ),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.lg),

                    // ── APP ────────────────────────────────────────────
                    _SectionTitle('APP', cs: cs),
                    const SizedBox(height: 8),
                    _MenuCard(
                      cs: cs,
                      items: [
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          iconColor: cs.primary,
                          label: 'Settings',
                          subtitle: 'Theme and font size',
                          onTap: () => context.push('/more/settings'),
                          cs: cs,
                        ),
                        _MenuItem(
                          icon: Icons.storage_rounded,
                          iconColor: cs.primary,
                          label: 'Data & Storage',
                          subtitle: 'Manage cache and progress',
                          onTap: () => context.push('/more/data'),
                          cs: cs,
                          showDividerAbove: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.lg),

                    // ── ABOUT ──────────────────────────────────────────
                    _SectionTitle('ABOUT', cs: cs),
                    const SizedBox(height: 8),
                    _MenuCard(
                      cs: cs,
                      items: [
                        _MenuItem(
                          icon: Icons.info_outline_rounded,
                          iconColor: cs.primary,
                          label: 'About this app',
                          subtitle: 'Version 1.0.0',
                          onTap: () => context.push('/more/about'),
                          cs: cs,
                        ),
                        _MenuItem(
                          icon: Icons.open_in_new_rounded,
                          iconColor: cs.primary,
                          label: 'Official Go tour',
                          subtitle: 'Opens go.dev/tour',
                          onTap: () => _openGoTour(),
                          cs: cs,
                          showDividerAbove: true,
                        ),
                      ],
                    ),

                    const SizedBox(height: KuberSpacing.xxl),
                    Center(
                      child: Text(
                        'Content from go.dev · BSD License',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
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

  Future<void> _confirmResetProgress(
      BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset progress?'),
        content:
            const Text('This will clear all completed lesson data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref.read(progressNotifierProvider.notifier).resetAll();
      await ref.read(lessonPositionNotifierProvider.notifier).goTo(
            kChapterOrder.first,
            0,
          );
      if (context.mounted) {
        showGoTourSnackBar(context, 'Progress cleared.');
      }
    }
  }

  Future<void> _openGoTour() async {
    final uri = Uri.parse('https://go.dev/tour/');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SectionTitle(this.label, {required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.3,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  final ColorScheme cs;
  const _MenuCard({required this.items, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(children: items),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool isDestructive;
  final VoidCallback onTap;
  final ColorScheme cs;
  final bool showDividerAbove;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    this.isDestructive = false,
    required this.onTap,
    required this.cs,
    this.showDividerAbove = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDestructive ? cs.error : iconColor;

    return Column(
      children: [
        if (showDividerAbove) Divider(height: 1, color: cs.outline),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            child: Row(
              children: [
                // Squircle icon with colored background
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(
                        color: effectiveColor.withValues(alpha: 0.25)),
                  ),
                  child: Icon(icon, size: 18, color: effectiveColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: isDestructive ? cs.error : cs.onSurface,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 16, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
