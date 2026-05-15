import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/progress_provider.dart';
import '../../../providers/tour_content_provider.dart';
import '../../../shared/widgets/go_tour_snackbar.dart';

class DataScreen extends ConsumerWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
                  ),
                  child: Icon(Icons.arrow_back_rounded, size: 18, color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
              Text('Data & Storage',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.6,
                  )),
              const SizedBox(height: 4),
              Text('Manage cache and progress.',
                  style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant)),
              const SizedBox(height: KuberSpacing.xl),
              _SectionLabel('PROGRESS', cs: cs),
              _Card(
                cs: cs,
                child: Column(
                  children: [
                    _ActionRow(
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
                            content: const Text('This will clear all completed lesson data.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          await ref.read(progressNotifierProvider.notifier).resetAll();
                          if (context.mounted) showGoTourSnackBar(context, 'Progress cleared.');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
              _SectionLabel('CONTENT', cs: cs),
              _Card(
                cs: cs,
                child: Column(
                  children: [
                    _ActionRow(
                      icon: Icons.refresh_rounded,
                      label: 'Re-fetch content',
                      subtitle: 'Download latest from go.dev',
                      iconColor: cs.primary,
                      cs: cs,
                      onTap: () async {
                        await ref.read(tourContentNotifierProvider.notifier).fetchFromApi();
                        if (context.mounted) showGoTourSnackBar(context, 'Content refreshed.');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SectionLabel(this.label, {required this.cs});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant, letterSpacing: 1.3)),
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
      decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(KuberRadius.md), border: Border.all(color: cs.outline)),
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
  const _ActionRow({required this.icon, required this.label, required this.subtitle, required this.iconColor, required this.cs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(KuberSpacing.md),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(KuberRadius.md), border: Border.all(color: iconColor.withValues(alpha: 0.3))),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w600, color: cs.onSurface)),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant)),
            ])),
            Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
