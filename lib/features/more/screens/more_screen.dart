import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/tour_models.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/lesson_position_provider.dart';
import '../../../shared/widgets/tourgo_app_bar.dart';
import '../../../shared/widgets/tourgo_page_header.dart';
import '../../../shared/widgets/go_tour_snackbar.dart';
import '../../gobyexample/widgets/download_sheet.dart';

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
              child: TourGoAppBar(showBack: true, title: ''),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page header
                    const TourGoPageHeader(
                      title: 'More',
                      description: 'Settings, data, and about.',
                    ),

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
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.lg),

                    // ── CONTENT ───────────────────────────────────────
                    _SectionTitle('CONTENT', cs: cs),
                    const SizedBox(height: 8),
                    _MenuCard(
                      cs: cs,
                      items: [
                        _MenuItem(
                          icon: Icons.download_for_offline_rounded,
                          iconColor: cs.primary,
                          label: 'Download All Examples',
                          subtitle:
                              'Save Go by Example content for offline use',
                          onTap: () => showGbeDownloadSheet(context),
                          cs: cs,
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
                          subtitle: 'Information and licenses',
                          onTap: () => context.push('/more/about'),
                          cs: cs,
                        ),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.lg),

                    // ── HELP US ─────────────────────────────────────────
                    _SectionTitle('HELP US', cs: cs),
                    const SizedBox(height: 8),
                    _HelpStrip(
                      actions: [
                        _HelpAction(
                          icon: Icons.star_rate_rounded,
                          label: 'Rate',
                          accent: _HelpAccent.warning,
                          onTap: () => launchUrl(
                            Uri.parse(
                              'https://play.google.com/store/apps/details?id=com.grs.tourgo',
                            ),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        _HelpAction(
                          icon: Icons.share_rounded,
                          label: 'Share',
                          onTap: () => SharePlus.instance.share(
                            ShareParams(
                              text:
                                  'Learn Go on the go! A Tour of Go is a '
                                  'beautifully simple companion for the official '
                                  'Go tour. Check it out: '
                                  'https://play.google.com/store/apps/details?id=com.grs.tourgo',
                            ),
                          ),
                        ),
                        _HelpAction(
                          icon: Icons.feedback_rounded,
                          label: 'Feedback',
                          onTap: () => context.push('/more/feedback'),
                        ),
                      ],
                    ),

                    const SizedBox(height: KuberSpacing.xxl),

                    // ── DANGER ──────────────────────────────────────────
                    _SectionTitle('DANGER ZONE', cs: cs),
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

  Future<void> _openUrl(String urlString) async {
    final uri = Uri.parse(urlString);
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

// ─────────────────────────────────────────────────────────────────────────────
// Help Us — 3-action strip (adapted from Kuber)
// ─────────────────────────────────────────────────────────────────────────────

enum _HelpAccent { primary, warning }

class _HelpAction {
  final IconData icon;
  final String label;
  final _HelpAccent accent;
  final VoidCallback onTap;
  _HelpAction({
    required this.icon,
    required this.label,
    this.accent = _HelpAccent.primary,
    required this.onTap,
  });
}

class _HelpStrip extends StatelessWidget {
  final List<_HelpAction> actions;
  const _HelpStrip({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          Expanded(child: _HelpTile(action: actions[i])),
          if (i < actions.length - 1) const SizedBox(width: KuberSpacing.sm),
        ],
      ],
    );
  }
}

class _HelpTile extends StatelessWidget {
  final _HelpAction action;
  const _HelpTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = switch (action.accent) {
      _HelpAccent.primary => cs.primary,
      _HelpAccent.warning => const Color(0xFFFFB300),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(KuberRadius.lg),
          ),
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.30),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(action.icon, size: 18, color: accentColor),
              ),
              const SizedBox(height: KuberSpacing.sm),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
